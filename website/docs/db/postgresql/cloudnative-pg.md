# CloudNativePG

|**Tool**|[CloudNativePG](https://cloudnative-pg.io)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|[pgadmin](https://www.pgadmin.org)|

## :white_check_mark: Setup

:::note Original cluster helm-chart
https://github.com/cloudnative-pg/charts/tree/main/charts/cluster
:::

```yaml
# https://github.com/cloudnative-pg/charts/blob/main/charts/cluster/examples/basic.yaml
# https://cloudnative-pg.io/documentation/1.26/samples/cluster-example-with-roles.yaml
cluster:
  type: postgresql
  mode: standalone
  version:
    postgresql: "16"
  cluster:
    instances: 1
    storage:
      size: 2Gi
  backups:
    enabled: false
```

## Usecases

### :white_check_mark: Basic: create db, create role, connect, etc.

- Connect

```bash
# creds in secret `postgres-cluster-superuser`
export PGPASSWORD=$(kubectl get secret postgres-cluster-superuser -n postgres -o jsonpath='{.data.password}' | base64 -d)
# do port-forward service `postgres-cluster-rw` to localhost
kubectl port-forward svc/postgres-cluster-rw -n portgres 5432:5432
# connect
psql -h localhost -p 5432 -U postgres -d postgres
```

- Create Roles

https://cloudnative-pg.io/documentation/1.26/declarative_role_management/

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  username: $(echo -n "dante" | base64)
  password: $(echo -n "dante" | base64)
kind: Secret
metadata:
  name: psql-role-dante
  namespace: postgres
  labels:
    cnpg.io/reload: "true"
type: kubernetes.io/basic-auth
EOF
```

```yaml
cluster:
  managed:
    roles:
    - name: app
      createdb: true
      login: true
    - name: dante
      ensure: present
      comment: my database-side comment
      login: true
      superuser: false
      createdb: true
      createrole: false
      inherit: false
      replication: false
      bypassrls: false
      connectionLimit: 4
      validUntil: "2053-04-12T15:04:05Z"
      inRoles:
        - pg_monitor
        - pg_signal_backend
      passwordSecret:
        name: psql-role-dante
```

- Create Database

https://cloudnative-pg.io/documentation/1.26/declarative_database_management/#postgresql-database-management

```bash
cat <<EOF | kubectl apply -f -
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: psql-db-postgres-cluster-dante
  namespace: postgres
spec:
  databaseReclaimPolicy: delete
  name: dante
  owner: postgres
  cluster:
    name: postgres-cluster
  schemas:
  - name: public
    owner: dante
  extensions:
  - name: bloom
    ensure: present
EOF
```

### Common: write data, read data, replication, etc.

### Advanced: external-secrets integrations (automation of password management)

## :white_check_mark: Monitoring

:::note Grafana Dashboard (operator + cluster)
https://grafana.com/grafana/dashboards/20417-cloudnativepg/
https://github.com/cloudnative-pg/grafana-dashboards
:::

```yaml
cloudnative-pg:
  monitoring:
    podMonitorEnabled: true
cluster:
  cluster:
    monitoring:
      enabled: true
```

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

## Patform integration

how this tool integrated into a platform
how to use it in a platform
how to debug

---

## Articles






