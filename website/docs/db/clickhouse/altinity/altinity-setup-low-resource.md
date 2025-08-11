# Altinity ClickHouse low resource setup

## ClickHouseKeeperInstallation

:::note Official single-node example
https://github.com/Altinity/clickhouse-operator/blob/master/docs/chk-examples/02-extended-1-node.yaml
:::

```yaml
apiVersion: "clickhouse-keeper.altinity.com/v1"
kind: "ClickHouseKeeperInstallation"
metadata:
  name: extended
  annotations:
    prometheus.io/port: "7000"
    prometheus.io/scrape: "true"
spec:
  configuration:
    clusters:
      - name: cluster1
        layout:
          replicasCount: 1
    settings:
      logger/level: "trace"
      logger/console: "true"
      listen_host: "0.0.0.0"
      keeper_server/four_letter_word_white_list: "*"
      keeper_server/coordination_settings/raft_logs_level: "information"
      prometheus/endpoint: "/metrics"
      prometheus/port: "7000"
      prometheus/metrics: "true"
      prometheus/events: "true"
      prometheus/asynchronous_metrics: "true"
      prometheus/status_info: "false"
  defaults:
    templates:
      # Templates are specified as default for all clusters
      podTemplate: default
      dataVolumeClaimTemplate: default
  templates:
    podTemplates:
      - name: default
        metadata:
          labels:
            app: clickhouse-keeper
          annotations:
            prometheus.io/port: "7000"
            prometheus.io/scrape: "true"
        spec:
          # affinity, remove it to allow use in single node test environment
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                      - key: "app"
                        operator: In
                        values:
                          - clickhouse-keeper
                  topologyKey: "kubernetes.io/hostname"
          containers:
            - name: clickhouse-keeper
              imagePullPolicy: IfNotPresent
              image: "clickhouse/clickhouse-keeper:latest"
              resources:
                requests:
                  memory: "256M"
                  cpu: "1"
                limits:
                  memory: "4Gi"
                  cpu: "2"
          securityContext:
            fsGroup: 101
    volumeClaimTemplates:
      - name: default
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
```

## ClickHouseInstallation for low resource environments

:::note Official doc
https://kb.altinity.com/altinity-kb-setup-and-maintenance/configure_clickhouse_for_low_mem_envs/
:::

Here's adjusted `ClickHouseInstallation` manifest for low resource environments, based on the official example

```yaml
apiVersion: "clickhouse.altinity.com/v1"
kind: "ClickHouseInstallation"
metadata:
  name: "clickhouse"
spec:
  configuration:
    settings:
      mysql_port: "0"
      postgresql_port: "0"
      mlock_executable: "false"  # Allow binary pages to be unloaded from RAM
      mark_cache_size: "268435456"  # 256 MB
      index_mark_cache_size: "67108864"  # 64 MB
      uncompressed_cache_size: "16777216"  # 16 MB
      max_thread_pool_size: "2000"
      max_connections: "64"
      max_concurrent_queries: "8"
      max_server_memory_usage_to_ram_ratio: "0.75"  # 75% of RAM for ClickHouse
      max_server_memory_usage: "0"  # Let overcommiter manage available RAM
      background_pool_size: "2"
      background_merges_mutations_concurrency_ratio: "2"
      merge_tree/merge_max_block_size: "1024"
      merge_tree/max_bytes_to_merge_at_max_space_in_pool: "1073741824"  # 1 GB max part
      merge_tree/number_of_free_entries_in_pool_to_lower_max_size_of_merge: "2"
      merge_tree/number_of_free_entries_in_pool_to_execute_mutation: "2"
      merge_tree/number_of_free_entries_in_pool_to_execute_optimize_entire_partition: "2"
      background_buffer_flush_schedule_pool_size: "1"
      background_merges_mutations_scheduling_policy: "round_robin"
      background_move_pool_size: "1"
      background_fetches_pool_size: "1"
      background_common_pool_size: "2"
      background_schedule_pool_size: "8"
      background_message_broker_schedule_pool_size: "1"
      background_distributed_schedule_pool_size: "1"
      tables_loader_foreground_pool_size: "0"
      tables_loader_background_pool_size: "0"
    files:
      config.d/disable_optional_logs.xml: |
        <clickhouse>
          <query_thread_log remove="1" />
          <opentelemetry_span_log remove="1" />
          <processors_profile_log remove="1" />
        </clickhouse>
    profiles:
      default/max_threads: "2"
      default/queue_max_wait_ms: "1000"
      default/max_execution_time: "600"
      default/input_format_parallel_parsing: "0"
      default/output_format_parallel_formatting: "0"
      default/max_bytes_before_external_group_by: "3221225472"  # 3 GB
      default/max_bytes_before_external_sort: "3221225472"  # 3 GB
    zookeeper:
      nodes:
        - host: chk-extended-cluster1-0-0
          port: 2181
      session_timeout_ms: 30000
      operation_timeout_ms: 10000
    clusters:
      - name: "clickhouse"
        layout:
          shardsCount: 1 # Do not use sharding for compatibility with Clickhouse Cloud
          replicasCount: 1
    users:
      dante/networks/ip: "::/0"
      dante/password: dante
      dante/profile: default
  templates:
    podTemplates:
      - name: clickhouse-pod
        spec:
          containers:
            - name: clickhouse
              image: clickhouse/clickhouse-server:24.8
              resources:
                requests:
                  memory: "2Gi"
                  cpu: "1"
                limits:
                  memory: "4Gi"
                  cpu: "2"
              readinessProbe:
                httpGet:
                  path: /ping
                  port: 8123
                initialDelaySeconds: 60
                timeoutSeconds: 10
                periodSeconds: 15
                failureThreshold: 10
    volumeClaimTemplates:
      - name: data-volume
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi

```
