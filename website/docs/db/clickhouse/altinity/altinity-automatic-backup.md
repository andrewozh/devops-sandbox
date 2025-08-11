# Automatic Clickhouse cluster backups and Restore guide

:::note Official Example
https://github.com/Altinity/clickhouse-backup/blob/master/Examples.md
:::

## Setup

- secret with `s3` credentials

```json
{
  "S3_ASSUME_ROLE_ARN": "arn:aws:iam::XXXXXXXXXXXX:role/clickhouse-backup",
  "S3_BUCKET": "clickhouse-backup",
  "S3_REGION": "us-west-2"
}
```

- fetch credentials with `ExternalSectet` (example)

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: "clickhouse-backup"
spec:
  refreshInterval: "180m"
  secretStoreRef:
    name: "aws-store"
    kind: SecretStore
  target:
    name: "clickhouse-backup"
    creationPolicy: Owner
    template:
      engineVersion: "v2"
      metadata:
        annotations:
          reloader.stakater.com/match: "true"
  dataFrom:
  - extract:
      key: "/clickhouse_backup"
```

- create `ConfigMap` with `clickhouse-backup` config

required values with shards and replicas count

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: "clickhouse-backup"
data:
  CLICKHOUSE_SERVICES: "{{- $shards := (.Values.clickhouse.shards | int) -}}{{- range $i := until $shards -}}{{- if $i -}},{{- end -}}chi-clickhouse-clickhouse-{{ $i }}-0{{- end }}"
  CLICKHOUSE_SCHEMA_RESTORE_SERVICES: "{{- $shards := (.Values.clickhouse.shards | int) -}}{{- range $i := until $shards -}}{{- if $i -}},{{- end -}}chi-clickhouse-clickhouse-{{ $i }}-0{{- end }}"
  CLICKHOUSE_DATA_RESTORE_SERVICES: "{{- $shards := (.Values.clickhouse.shards | int) -}}{{- $replicas := (.Values.clickhouse.replicas | int) -}}{{- range $i := until $shards -}}{{- range $j := until $replicas -}}{{- if or $i $j -}},{{- end -}}chi-clickhouse-clickhouse-{{ $i }}-{{ $j }}{{- end -}}{{- end }}"
  CLICKHOUSE_PORT: "9000"
  BACKUP_USER: "default"
  BACKUP_PASSWORD: ""
```

- configure sidecar

```yaml
apiVersion: "clickhouse.altinity.com/v1"
kind: "ClickHouseInstallation"
spec:
  templates:
    podTemplates:
      - name: clickhouse
        spec:
          containers:
            - name: backup-server
              image: altinity/clickhouse-backup:master
              imagePullPolicy: Always
              command:
                - bash
                - -xc
                - "/bin/clickhouse-backup server"
              env:
                # - name: LOG_LEVEL
                #   value: "debug"
                - name: ALLOW_EMPTY_BACKUPS
                  value: "true"
                - name: API_LISTEN
                  value: "0.0.0.0:7171"
                - name: API_CREATE_INTEGRATION_TABLES
                  value: "true"
                - name: BACKUPS_TO_KEEP_REMOTE
                  value: "3"
                - name: REMOTE_STORAGE
                  value: "s3"
                - name: S3_ACL
                  value: "private"
                - name: S3_PATH
                  value: backup/shard-{shard}
                - name: S3_FORCE_PATH_STYLE
                  value: "true"
                # - name: S3_DEBUG
                #   value: "true"
              envFrom:
                - secretRef:
                   name: clickhouse-backup
              ports:
                - name: backup-rest
                  containerPort: 7171
```

## Automatic backups CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: clickhouse-backup-cron
spec:
  suspend: true
  schedule: "0 0 * * *"
  concurrencyPolicy: "Forbid"
  jobTemplate:
    spec:
      backoffLimit: 1
      completions: 1
      parallelism: 1
      template:
        metadata:
          labels:
            app: clickhouse-backup-cron
        spec:
          restartPolicy: Never
          containers:
            - name: run-backup-cron
              image: "altinity/clickhouse-server:latest"
              imagePullPolicy: IfNotPresent
              envFrom:
                - configMapRef:
                    name: "clickhouse-backup"
                - secretRef:
                    name: "clickhouse-backup"
              env:
                - name: MAKE_INCREMENT_BACKUP
                  value: "1"
                - name: FULL_BACKUP_WEEKDAY
                  value: "1"
              command:
                - bash
                - -ec
                - CLICKHOUSE_SERVICES=$(echo $CLICKHOUSE_SERVICES | tr "," " ");
                  BACKUP_DATE=$(date +%Y-%m-%d-%H-%M-%S);
                  declare -A BACKUP_NAMES;
                  declare -A DIFF_FROM;
                  if [[ "" != "$BACKUP_PASSWORD" ]]; then
                    BACKUP_PASSWORD="--password=$BACKUP_PASSWORD";
                  fi;
                  for SERVER in $CLICKHOUSE_SERVICES; do
                    if [[ "1" == "$MAKE_INCREMENT_BACKUP" ]]; then
                      LAST_FULL_BACKUP=$(clickhouse-client -q "SELECT name FROM system.backup_list WHERE location='remote' AND name LIKE '%${SERVER}%' AND name LIKE '%full%' AND desc NOT LIKE 'broken%' ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);
                      TODAY_FULL_BACKUP=$(clickhouse-client -q "SELECT name FROM system.backup_list WHERE location='remote' AND name LIKE '%${SERVER}%' AND name LIKE '%full%' AND desc NOT LIKE 'broken%' AND toDate(created) = today() ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD)
                      PREV_BACKUP_NAME=$(clickhouse-client -q "SELECT name FROM system.backup_list WHERE location='remote' AND desc NOT LIKE 'broken%' ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);
                      DIFF_FROM[$SERVER]="";
                      if [[ ("$FULL_BACKUP_WEEKDAY" == "$(date +%u)" && "" == "$TODAY_FULL_BACKUP") || "" == "$PREV_BACKUP_NAME" || "" == "$LAST_FULL_BACKUP" ]]; then
                        BACKUP_NAMES[$SERVER]="full-$BACKUP_DATE";
                      else
                        BACKUP_NAMES[$SERVER]="increment-$BACKUP_DATE";
                        DIFF_FROM[$SERVER]="--diff-from-remote=$PREV_BACKUP_NAME";
                      fi
                    else
                      BACKUP_NAMES[$SERVER]="full-$BACKUP_DATE";
                    fi;
                    echo "set backup name on $SERVER = ${BACKUP_NAMES[$SERVER]}";
                  done;
                  for SERVER in $CLICKHOUSE_SERVICES; do
                    echo "create ${BACKUP_NAMES[$SERVER]} on $SERVER";
                    clickhouse-client --echo -mn -q "INSERT INTO system.backup_actions(command) VALUES('create ${SERVER}-${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
                  done;
                  for SERVER in $CLICKHOUSE_SERVICES; do
                    while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='create ${SERVER}-${BACKUP_NAMES[$SERVER]}' FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
                      echo "still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER";
                      sleep 1;
                    done;
                    if [[ "success" != $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='create ${SERVER}-${BACKUP_NAMES[$SERVER]}' FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; then
                      echo "error create ${BACKUP_NAMES[$SERVER]} on $SERVER";
                      clickhouse-client -mn --echo -q "SELECT status,error FROM system.backup_actions WHERE command='create ${SERVER}-${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
                      exit 1;
                    fi;
                  done;
                  for SERVER in $CLICKHOUSE_SERVICES; do
                    echo "upload ${DIFF_FROM[$SERVER]} ${BACKUP_NAMES[$SERVER]} on $SERVER";
                    clickhouse-client --echo -mn -q "INSERT INTO system.backup_actions(command) VALUES('upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
                  done;
                  for SERVER in $CLICKHOUSE_SERVICES; do
                    while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
                      echo "upload still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER";
                      sleep 5;
                    done;
                    if [[ "success" != $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; then
                      echo "error ${BACKUP_NAMES[$SERVER]} on $SERVER";
                      clickhouse-client -mn --echo -q "SELECT status,error FROM system.backup_actions WHERE command='upload ${DIFF_FROM[$SERVER]} ${SERVER}-${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
                      exit 1;
                    fi;
                    clickhouse-client --echo -mn -q "INSERT INTO system.backup_actions(command) VALUES('delete local ${SERVER}-${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
                  done;
                  echo "BACKUP CREATED"
```

## List available backups

```bash
kubectl get pods -n clickhouse -l clickhouse.altinity.com/replica="0" -o jsonpath="{.items[*].metadata.name}" | xargs -n1 -I% kubectl exec -n clickhouse -it % --container backup-server -- env LOG_LEVEL=error clickhouse-backup list
```

## Restore everything

* fill required `env` params:

`TABLE` -- format `<DB>.<TABLE>` regex supported
`BACKUP_DATE` -- format `2024-03-27`, left empty to use last available 

```yaml
env:
  - name: TABLE
    value: 'db.table*'
  - name: BACKUP_DATE
    value: "2024-03-27"
```

* apply restore job

```yaml
cat <<'EOF' | kubectl apply -f -
---
apiVersion: batch/v1
kind: Job
metadata:
  name: clickhouse-restore
  namespace: clickhouse
spec:
  backoffLimit: 0
  template:
    metadata:
      name: clickhouse-backup-restore
      labels:
        app: clickhouse-backup-restore
    spec:
      restartPolicy: Never
      containers:
      - name: clickhouse-backup-restore
        image: clickhouse/clickhouse-client:latest
        imagePullPolicy: IfNotPresent
        envFrom:
          - configMapRef:
              name: "clickhouse-backup"
          - secretRef:
              name: "clickhouse-backup"
        env:
          - name: TABLE
            value: 'test.*_table2'
          - name: BACKUP_DATE
            value: 2024-03-27
        command:
        - bash
        - -ec
        - if [[ "" != "$BACKUP_PASSWORD" ]]; then
            BACKUP_PASSWORD="--password=$BACKUP_PASSWORD";
          fi;
          declare -A BACKUP_NAMES;
          CLICKHOUSE_SCHEMA_RESTORE_SERVICES=$(echo $CLICKHOUSE_SCHEMA_RESTORE_SERVICES | tr "," " ");
          CLICKHOUSE_DATA_RESTORE_SERVICES=$(echo $CLICKHOUSE_DATA_RESTORE_SERVICES | tr "," " ");
          for SERVER in $CLICKHOUSE_SCHEMA_RESTORE_SERVICES; do
            LATEST_BACKUP_NAME=$(clickhouse-client -q "SELECT name FROM system.backup_list WHERE location='remote' AND desc NOT LIKE 'broken%' AND name LIKE '%${SERVER}%${BACKUP_DATE}%' ORDER BY created DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);
            if [[ "" == "$LATEST_BACKUP_NAME" ]]; then
              echo "Remote backup not found for $SERVER";
              exit 1;
            fi;
            BACKUP_NAMES[$SERVER]="$LATEST_BACKUP_NAME";
            clickhouse-client -mn --echo -q "INSERT INTO system.backup_actions(command) VALUES('restore_remote --schema --rm -t ${TABLE} ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
          done;
          for SERVER in $CLICKHOUSE_SCHEMA_RESTORE_SERVICES; do
            while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --schema --rm -t ${TABLE} ${BACKUP_NAMES[$SERVER]}' ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
              echo "still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER";
              sleep 1;
            done;
            RESTORE_STATUS=$(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --schema --rm -t ${TABLE} ${BACKUP_NAMES[$SERVER]}'  ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);
            if [[ "success" != "${RESTORE_STATUS}" ]]; then
              echo "error restore_remote --schema --rm -t ${TABLE} ${BACKUP_NAMES[$SERVER]} on $SERVER";
              clickhouse-client -mn --echo -q "SELECT start,finish,status,error FROM system.backup_actions WHERE command='restore_remote --schema --rm -t ${TABLE} ${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
              exit 1;
            fi;
            if [[ "success" == "${RESTORE_STATUS}" ]]; then
              echo "schema ${BACKUP_NAMES[$SERVER]} on $SERVER RESTORED";
              clickhouse-client -q "INSERT INTO system.backup_actions(command) VALUES('delete local ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
            fi;
          done;
          for SERVER in $CLICKHOUSE_DATA_RESTORE_SERVICES; do
            clickhouse-client -mn --echo -q "INSERT INTO system.backup_actions(command) VALUES('restore_remote --data -t ${TABLE} ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
          done;
          for SERVER in $CLICKHOUSE_DATA_RESTORE_SERVICES; do
            while [[ "in progress" == $(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --data -t ${TABLE} ${BACKUP_NAMES[$SERVER]}' ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
              echo "still in progress ${BACKUP_NAMES[$SERVER]} on $SERVER";
              sleep 1;
            done;
            RESTORE_STATUS=$(clickhouse-client -mn -q "SELECT status FROM system.backup_actions WHERE command='restore_remote --data -t ${TABLE} ${BACKUP_NAMES[$SERVER]}'  ORDER BY start DESC LIMIT 1 FORMAT TabSeparatedRaw" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD);
            if [[ "success" != "${RESTORE_STATUS}" ]]; then
              echo "error restore_remote --data -t ${TABLE} ${BACKUP_NAMES[$SERVER]} on $SERVER";
              clickhouse-client -mn --echo -q "SELECT start,finish,status,error FROM system.backup_actions WHERE command='restore_remote --data -t ${TABLE} ${BACKUP_NAMES[$SERVER]}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
              exit 1;
            fi;
            echo "data ${BACKUP_NAMES[$SERVER]} on $SERVER RESTORED";
            if [[ "success" == "${RESTORE_STATUS}" ]]; then
              clickhouse-client -q "INSERT INTO system.backup_actions(command) VALUES('delete local ${BACKUP_NAMES[$SERVER]}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
            fi;
          done
EOF
```
