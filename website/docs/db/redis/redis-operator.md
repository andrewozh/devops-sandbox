---
tags:
- distro
- redis-operator
- redis
- database
---

# Redis Operator by OpsTree

|**Distro**|[Redis Operator by OpsTree](https://github.com/ot-container-kit/redis-operator)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](https://redis-operator.opstree.dev/docs/)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|web|

## :white_check_mark: Setup

:::warning Redis configuration
- **Redis Cluster** = Minimum 3 masters (for sharding data)
- **Redis Replication** = 1 master + N replicas (for HA without sharding)
- **Redis Standalone** = Single instance (simplest setup)
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

### :white_check_mark: Basic: create writter/reader users

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

- verify and connect

```bash
$  kubectl exec -it redis-operator-leader-0 -n redis -- redis-cli -a redis
Defaulted container "redis-operator-leader" out of: redis-operator-leader, redis-exporter
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> acl list
1) "user admin on #8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918 ~* &* +@all"
2) "user default on #34fb46c847bb9df96e5205a39d382f648a6e8dce1e014cd85b4ca6a88d88ed03 ~* &* +@all"
3) "user reader on #3d0941964aa3ebdcb00ccef58b1bb399f9f898465e9886d5aec7f31090a0fb30 ~* &* -@all +@read -sort_ro -keys"
4) "user writer on #b93006774cbdd4b299389a03ac3d88c3a76b460d538795bc12718011a909fba5 ~app:* resetchannels -@all +@string +@hash +@geo +@blocking +@bitmap +@set +@hyperloglog +@stream +@sortedset +@list +@keyspace -sort +function|restore +function|flush +function|load +function|delete -sort_ro -object|help -restore-asking -keys +lolwut -flushall -swapdb -pfdebug -xgroup|help -migrate -restore -flushdb -xinfo|help -pfselftest +memory|usage"
127.0.0.1:6379>

$  kubectl exec -it redis-operator-leader-0 -n redis -- redis-cli --user reader --pass reader
Defaulted container "redis-operator-leader" out of: redis-operator-leader, redis-exporter
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379>
```

- write/read key

```bash
$  kubectl exec -it redis-operator-leader-0 -n redis -- redis-cli --user writer --pass writer
Defaulted container "redis-operator-leader" out of: redis-operator-leader, redis-exporter
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> keys *
(error) NOPERM this user has no permissions to run the 'keys' command
127.0.0.1:6379> set hello "world"
(error) NOPERM this user has no permissions to access one of the keys used as arguments
127.0.0.1:6379> set app:hello "world"
OK
127.0.0.1:6379> exit

$  kubectl exec -it redis-operator-leader-0 -n redis -- redis-cli --user reader --pass reader
Defaulted container "redis-operator-leader" out of: redis-operator-leader, redis-exporter
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> get app:hello
"world"
127.0.0.1:6379> keys app:*
(error) NOPERM this user has no permissions to run the 'keys' command
127.0.0.1:6379> exit
```

### Common:

## :white_check_mark: Monitoring

:::note Grafana Dashboard
https://github.com/OT-CONTAINER-KIT/redis-operator/blob/main/dashboards/redis-operator-cluster.json
(my fixed version in kube-prometheus-stack/dashboards/)
:::

```yaml
redis-cluster:
  serviceMonitor:
    enabled: true
    namespace: redis
  redisExporter:
    enabled: true
```

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Example article link](#)
