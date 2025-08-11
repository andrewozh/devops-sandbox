# Self-hosted Altinity Clickhouse and Clickhouse Cloud compatibility

## Cloud

- CREATE DATABASE can't be used with ON CLUSTER
- name of clickhouse cloud service can be used as cluster name while creating tables, views, etc. ON CLUSTER
- `default` cluster exist but can't be used in ON CLUSTER
- use custom zookeeper path without `{uuid}` (because it's not supported by self-hosted)
- always specify Replicated table engine in migrations to backward compatibility with self-hosted
