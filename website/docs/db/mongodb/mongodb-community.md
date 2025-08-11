# MongoDB Community

|**Distro**|[Mongodb Controllers for Kubernetes](https://github.com/mongodb/mongodb-kubernetes)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](https://github.com/mongodb/mongodb-kubernetes/tree/master/docs/mongodbcommunity)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**||

## :white_check_mark: Setup

:::note All setup is done via the `MongoDBCommunity` custom resource
[Community Operator Architecture](https://github.com/mongodb/mongodb-kubernetes/blob/master/docs/mongodbcommunity/architecture.md)
:::

## Usecases

### :white_check_mark: Basic: create db, create user, connect, etc.

- Databases

There is no database creation, just create user and assign a `dbOwner` role to it (example forward)

- Create user

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mongo-admin-user
  namespace: mongo
type: Opaque
stringData:
  password: admin123
EOF
```

```yaml
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: mongodb
spec:
  members: 1
  type: ReplicaSet
  version: "8.0.11"
  security:
    authentication:
      modes:
      - SCRAM
  users:
  - name: admin-user
    db: admin
    passwordSecretRef:
      name: mongo-admin-user
    roles:
    - name: clusterAdmin
      db: admin
    - name: userAdminAnyDatabase
      db: admin
    scramCredentialsSecretName: my-scram
  - name: test-user
    db: test
    passwordSecretRef:
      name: mongo-admin-user
    roles:
    - name: dbOwner
      db: test
    scramCredentialsSecretName: test-scram
```

- Connect

Port-forward service `mongodb-svc` to localhost

```bash
mongosh "mongodb://test-user:admin123@127.0.0.1:27017/test"
```

### Common: write data, read data, replication, etc.

## :white_check_mark: Monitoring

:::tip Monitoring setup example
https://github.com/mongodb/mongodb-kubernetes/blob/master/docs/mongodbcommunity/prometheus/mongodb-prometheus-sample.yaml
:::

:::tip Grafana Dashboard
https://github.com/mongodb/mongodb-kubernetes/blob/master/docs/mongodbcommunity/grafana/sample_dashboard.json
:::

- add secret with credentials for prometheus metrics endpoint

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-prometheus-user
  namespace: mongo
type: Opaque
stringData:
  password: prometheus
  username: prometheus
EOF
```

- update `MongoDBCommunity` resource with prometheus conf

```yaml
spec:
  prometheus:
    username: prometheus
    passwordSecretRef:
      name: mongodb-prometheus-user
```

- create `ServiceMonitor` for prometheus

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  annotations:

  # This needs to match `spec.ServiceMonitorSelector.matchLabels` from your
  # `prometheuses.monitoring.coreos.com` resouce.
  labels:
    release: prometheus

  name: mongodb-servicemonitor
spec:
  endpoints:

  # Configuring a Prometheus Endpoint with basic Auth.
  # `prom-secret` is a Secret containing a `username` and `password` entries.
  - basicAuth:
      password:
        key: password
        name: mongodb-prometheus-user
      username:
        key: username
        name: mongodb-prometheus-user

    # This port matches what we created in our MongoDB Service.
    port: prometheus

    # If using HTTPS enabled endpoint, change scheme to https
    scheme: http

    # Configure different TLS related settings. For more information, see:
    # https://github.com/prometheus-operator/prometheus-operator/blob/main/pkg/apis/monitoring/v1/types.go#L909
    # tlsConfig:
    #    insecureSkipVerify: true

  # What namespace to watch
  namespaceSelector:
    matchNames:
    - {{ .Release.Namespace }}

  # Service labels to match
  selector:
    matchLabels:
      app: mongodb-svc
```

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles
