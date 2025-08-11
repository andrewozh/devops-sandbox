# Altinity Clickhouse Operator

|**Distro**|[Altinity Clickhouse Operator](https://altinity.com/kubernetes-operator/)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](https://docs.altinity.com/altinitykubernetesoperator/), [github](https://github.com/Altinity/clickhouse-operator/tree/master/docs)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|web|

## :white_check_mark: Setup

* [Altinity Clickhouse low resources setup](./altinity-setup-low-resource.md)

## Usecases

### :white_check_mark: Basic: create db, create user, connect, etc.

- Connect

```bash
kubectl exec -it chi-clickhouse-clickhouse-0-0-0 -n clickhouse -- clickhouse-client
ClickHouse client version 25.7.2.54 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 25.7.2.

chi-clickhouse-clickhouse-0-0-0.chi-clickhouse-clickhouse-0-0.clickhouse.svc.cluster.local :)
```

- Create a user by configuring `ClickHouseInstallation` resource

```yaml
spec:
  configuration:
    users:
      dante/networks/ip: "::/0"
      dante/password: dante
      dante/profile: default
```

- Create a database

```bash
kubectl exec -it chi-clickhouse-clickhouse-0-0-0 -n clickhouse -- clickhouse-client \
  --host localhost \
  --port 9000 \
  --user dante \
  --password dante \
  --query="CREATE DATABASE IF NOT EXISTS dante ON CLUSTER clickhouse"
```

- Connect to the database

```bash
kubectl exec -it chi-clickhouse-clickhouse-0-0-0 -n clickhouse -- clickhouse-client \
  --host localhost \
  --port 9000 \
  --user dante \
  --password dante \
  --database dante
```

### Common: Create replicated table, write/read data, automate db/user provision

- db provision / user provision

`PushSecret` -> vault -> `ExternalSecret` -> Secret: `users.xml` -> volume: `ClickhouseInstallation`

```yaml
host: "clickhouse-clickhouse.clickhouse.svc.cluster.local"
hostRegexp: '(chi-clickhouse-[^.]+\d+-\d+|clickhouse\-clickhouse)\.clickhouse\.svc\.cluster\.local$'
```

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: "clickhouse-users-secret"
spec:
  refreshInterval: 15m
  secretStoreRef:
    name: "vault"
    kind: SecretStore
  target:
    name: "clickhouse-users-secret"
    creationPolicy: Owner
    template:
      engineVersion: v2
      metadata:
        annotations:
          reloader.stakater.com/match: "true"
      data:
        users.xml: |
          <clickhouse>
              <profiles>
                  <default>
                  </default>
                  <readonly>
                      <readonly>1</readonly>
                  </readonly>
              </profiles>
              <users>
                  <default>
                      <password></password>
                      <networks>
                          <ip>::/0</ip>
                      </networks>
                      <profile>default</profile>
                      <quota>default</quota>
                  </default>
                  {{ "{{" }}- range $key, $value := . -{{ "}}" }}
                  {{ "{{" }}- $decodedValue := ( $value | fromJson ) -{{ "}}" }}
                  {{ "{{" }}- $db := coalesce (get $decodedValue "CLICKHOUSE_DB") (get $decodedValue "CLICKHOUSE_DB_NAME") (get $decodedValue "CLICKHOUSE_DATABASE") -{{ "}}" }}
                  {{ "{{" }}- $user := get $decodedValue "CLICKHOUSE_USER" -{{ "}}" }}
                  {{ "{{" }}- $password := get $decodedValue "CLICKHOUSE_PASSWORD" -{{ "}}" }}
                  {{ "{{" }}- if and $user (ne $user "default") -{{ "}}" }}
                  <{{ "{{" }} $user {{ "}}" }}>
                    <allow_databases>
                      <database>{{ "{{" }} $db {{ "}}" }}</database>
                    </allow_databases>
                    <networks>
                      <host_regexp>{{ .Values.hostRegexp }}</host_regexp>
                      {{- include "clickhouse.cidrRangeXml" $ | indent 22 }}
                    </networks>
                    <password>{{ "{{" }} $password {{ "}}" }}</password>
                    <profile>default</profile>
                    <quota>default</quota>
                  </{{ "{{" }} $user {{ "}}" }}>
                  {{ "{{" }}- end -{{ "}}" }}
                  {{ "{{" }}- end -{{ "}}" }}
              </users>
              <quotas>
                  <default>
                      <interval>
                          <duration>3600</duration>
                          <queries>0</queries>
                          <errors>0</errors>
                          <result_rows>0</result_rows>
                          <read_rows>0</read_rows>
                          <execution_time>0</execution_time>
                      </interval>
                  </default>
              </quotas>
          </clickhouse>
        initdb.sh: |
          {{ "{{" }}- range $key, $value := . -{{ "}}" }}
          {{ "{{" }}- $decodedValue := ( $value | fromJson ) -{{ "}}" }}
          {{ "{{" }}- $db := coalesce (get $decodedValue "CLICKHOUSE_DB") (get $decodedValue "CLICKHOUSE_DB_NAME") (get $decodedValue "CLICKHOUSE_DATABASE") -{{ "}}" }}
          {{ "{{" }}- $user := get $decodedValue "CLICKHOUSE_USER" -{{ "}}" }}
          {{ "{{" }}- $password := get $decodedValue "CLICKHOUSE_PASSWORD" -{{ "}}" }}
          {{ "{{" }}- if and $user (ne $user "default") -{{ "}}" }}
          echo "CREATE DATABASE IF NOT EXISTS {{ "{{" }} $db {{ "}}" }} ON CLUSTER clickhouse" ;
          clickhouse-client --host {{ .Values.host }} --user {{ "{{" }} $user {{ "}}" }} --password {{ "{{" }} $password {{ "}}" }} --query="CREATE DATABASE IF NOT EXISTS {{ "{{" }} $db {{ "}}" }} ON CLUSTER clickhouse" ;
          {{ "{{" }}- end -{{ "}}" }}
          {{ "{{" }}- end -{{ "}}" }}
  dataFrom:
  - find:
      conversionStrategy: Default
      decodingStrategy: None
      path: /clickhouse
      tags:
        environment: common
        use_clickhouse: "true"
```

- schedule automatic database creation

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: "clickouse-initdb"
  annotations:
    reloader.stakater.com/auto: "true"
spec:
  schedule: "0 0 1 * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: initdb
            image: "altinity/clickhouse-server:latest"
            command: ["/bin/bash"]
            args: ["/etc/clickhouse-client/initdb.sh"]
            volumeMounts:
              - name: "clickhouse-initdb-volume"
                mountPath: "/etc/clickhouse-client/initdb.sh"
                subPath: initdb.sh
          volumes:
          - name: "clickhouse-initdb-volume"
            secret:
              secretName: "clickhouse-users-secret"
              items:
              - key: initdb.sh
                path: initdb.sh
          restartPolicy: OnFailure
```

## :white_check_mark: Monitoring

:::note Grafana Dashboard
https://github.com/Altinity/clickhouse-operator/blob/2ed803c6acba00a371bcf0877ab3784895b41add/grafana-dashboard/Altinity_ClickHouse_Operator_dashboard.json
:::

```yaml
altinity-clickhouse-operator:
  serviceMonitor:
    enabled: true
  dashboards:
    enabled: true
    annotations:
      argocd.argoproj.io/sync-options: ServerSideApply=true
    additionalLabels:
      grafana_dashboard: "1"
```

## Maintenence

- [Automatic Clickhouse cluster backups and Restore guide](./altinity-automatic-backup.md) -- todo
- Scaling
- Upgrade

---

## Articles

* [Example article link](#)
