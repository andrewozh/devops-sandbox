# Redis Operator by OpsTree

|**Distro**|[Example](#)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](#)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|web|

## Setup

:::warn Redis configuration
**Redis Cluster** = Minimum 3 masters (for sharding data)
**Redis Replication** = 1 master + N replicas (for HA without sharding)
**Redis Standalone** = Single instance (simplest setup)
:::

- create admin password secret

```bash
kubectl create secret generic redis-secret --from-literal=password=redis -n redis
```

- redis-cluster setup

```yaml
redis-cluster:
  rediscluster:
    clustersize: 3
    leader:
      replicas: 3
    follower:
      replicas: 3
    redisSecret:
      secretName: "redis-secret"
      secretKey: "password"
```

- connect

```bash
kubectl exec -it redis-operator-leader-0 -n redis -- redis-cli -a redis
```

## Usecases

### Basic: create writter/reader users

- `users.acl` secret

:::tip
[Redis ACL Guide](redis-acl-rules.md)
:::

:::warn
In `ACL` mode default user must be configured with `on` and `>password` to allow access or disabled.
This will replace the `rediscluster.redisSecret` configuration
:::

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redis-users-acl
stringData:
  users.acl: |
    user default on ~* &* +@all >redis
    user admin on ~* &* +@all >admin
    user reader on +@read ~* &* -@dangerous >reader
    user writer on +@write +@read ~app:* -@dangerous >writer
```

- configure `RedisCluster`

```yaml
redis-cluster:
  acl:
    secret:
      secretName: "redis-users-acl"
```

### Common: write data, read data, replication, etc.

## Monitoring

:::note Grafana Dashboard
https://github.com/OT-CONTAINER-KIT/redis-operator/blob/main/dashboards/redis-operator-cluster.json
:::

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Example article link](#)
