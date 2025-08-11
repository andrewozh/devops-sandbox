# Strimzi Kafka Operator

|**Distro**|[Strimzi Kafka Operator](https://github.com/strimzi/strimzi-kafka-operator)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](https://strimzi.io/documentation/)|
|**Backup**||
|**Scaling**||
|**CLI**|kafkacat|
|**UI**|[kafka-ui](https://github.com/provectus/kafka-ui) (web)|

## Setup

:::info
Run on default configuration
:::

**Kafka Bridge** provides a RESTful interface that allows HTTP-based clients to interact with a Kafka cluster.

**Mirror Maker** is a tool for replicating data between Kafka clusters, which can be useful for disaster recovery or data migration.

## Usecases

### :white_check_mark: Basic: create cluster, create user, create topic, connect

- Single-node cluster configuration

use `KafkaNodePool` to create zookeeper-less cluster with KRaft mode enabled

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaNodePool
metadata:
  name: single-node
  labels:
    strimzi.io/cluster: kafka-cluster
spec:
  replicas: 1
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 2Gi
        deleteClaim: true
        kraftMetadata: shared
```

Kafka cluster configuration, pay attention to:

* `.spec.kafka.listeners` -- defines the listeners for the Kafka cluster, including authentication methods.

* `.spec.kafka.authorization` -- defines the authorization type and super users.

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: kafka-cluster
  annotations:
    strimzi.io/node-pools: enabled
    strimzi.io/kraft: enabled
spec:
  kafka:
    version: 4.0.0
    metadataVersion: 4.0-IV3
    authorization:
      type: simple
      superUsers:
        - admin-kafka-user
    listeners:
      - name: plain # need to stay without auth for proper broker communication
        port: 9092
        type: internal
        tls: false
      - name: internal # add port to main brokers service with scram-sha-512 auth
        port: 9095
        type: internal
        tls: false
        authentication:
          type: scram-sha-512
      - name: tls
        port: 9093
        type: internal
        tls: true
      - name: portforward  # special service configured to be used with port-forward
        port: 9094
        type: nodeport
        tls: false
        authentication:
          type: scram-sha-512
        configuration:
          bootstrap:
            nodePort: 30094
          brokers:
          - broker: 0
            nodePort: 30664
            advertisedHost: localhost
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
      auto.create.topics.enable: false
      delete.topic.enable: true
  entityOperator:
    topicOperator: {}
    userOperator: {}
```

- Topic

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: dante-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: kafka-cluster
spec:
  partitions: 10
  replicas: 1
```

- Users

admin user list in `Kafka` resource `.spec.kafka.authorization.superUsers`

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: admin-kafka-user
  namespace: kafka
  labels:
    strimzi.io/cluster: kafka-cluster
spec:
  authentication:
    type: scram-sha-512
```

user with access to `topic`` and `consumer group`

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: dante-kafka-user
  namespace: kafka
  labels:
    strimzi.io/cluster: kafka-cluster
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
    - resource:
        type: topic
        name: dante-topic
      operations:
        - Describe
        - Read
        - Write
      host: "*"
    - resource:
        type: group
        name: dante-group
        patternType: prefix
      operations:
        - Describe
        - Read
      host: "*"
```

- Produce and Consume messages internally

our users need scram-sha-512 auth, so we can use only internal listener with `scram-sha-512` authentication enabled (on 9095 port)

```bash
# create properties files with scram-sha-512 creds
for user in dante-kafka-user admin-kafka-user; do
  cat <<EOF | kubectl exec -i kafka-cluster-single-node-0 -n kafka -c kafka -- sh -c 'cat > /tmp/'${user}'.properties'
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="$user" password="$(kubectl get secret $user -n kafka -o jsonpath='{.data.password}' | base64 -d)";
EOF
done

# produce message as dante
./bin/kafka-console-producer.sh \
  --bootstrap-server kafka-cluster-kafka-bootstrap:9095 \
  --producer.config /tmp/dante-kafka-user.properties \
  --topic dante-topic
>Hello

# produce message as admin
./bin/kafka-console-producer.sh \
  --bootstrap-server kafka-cluster-kafka-bootstrap:9095 \
  --producer.config /tmp/admin-kafka-user.properties \
  --topic dante-topic
>world

# consume as admin
./bin/kafka-console-consumer.sh \
  --bootstrap-server kafka-cluster-kafka-bootstrap:9095 \
  --producer.config /tmp/dante-kafka-user.properties \
  --topic dante-topic --from-beginning
Hello
world
^CProcessed a total of 2 messages

# consume as dante
./bin/kafka-console-consumer.sh \
  --bootstrap-server kafka-cluster-kafka-bootstrap:9095 \
  --producer.config /tmp/dante-kafka-user.properties \
  --topic dante-topic --from-beginning
Hello
world
^CProcessed a total of 2 messages
```

- Access Kafka cluster via `port-forward`

port-forwarding listener explained:

```yaml
      - name: portforward  # special service configured to be used with port-forward
        port: 9094
        type: nodeport
        tls: false
        authentication:
          type: scram-sha-512
        configuration:
          bootstrap:
            nodePort: 30094
          brokers:
          - broker: 0
            nodePort: 30664 # each brokers port have to be port-forwarded
            advertisedHost: localhost # because afer port-forwarding we will access it via localhost
```

```bash
kubectl --context kind-homelab port-forward svc/kafka-cluster-single-node-portforward-0 30664:9094 -n kafka
kubectl --context kind-homelab port-forward svc/kafka-cluster-kafka-portforward-bootstrap 9094:9094 -n kafka

kcat -b localhost:9094 \
  -X security.protocol=SASL_PLAINTEXT \
  -X sasl.mechanism=SCRAM-SHA-512 \
  -X sasl.username=dante-kafka-user \
  -X sasl.password=qBD7sXygrJWuAfAZls8Uyr4qo26wPI9k \
  -L
Metadata for all topics (from broker 0: sasl_plaintext://localhost:30664/0):
 1 brokers:
  broker 0 at localhost:30664 (controller)
 1 topics:
  topic "dante-topic" with 10 partitions:
    partition 0, leader 0, replicas: 0, isrs: 0
    partition 1, leader 0, replicas: 0, isrs: 0
    partition 2, leader 0, replicas: 0, isrs: 0
    partition 3, leader 0, replicas: 0, isrs: 0
    partition 4, leader 0, replicas: 0, isrs: 0
    partition 5, leader 0, replicas: 0, isrs: 0
    partition 6, leader 0, replicas: 0, isrs: 0
    partition 7, leader 0, replicas: 0, isrs: 0
    partition 8, leader 0, replicas: 0, isrs: 0
    partition 9, leader 0, replicas: 0, isrs: 0
```

### :arrows_counterclockwise: Common: produce message to topic, consume from topic, consumer group

```bash
$  echo "Hello from kcat" | kcat -b localhost:9094 \
  -X security.protocol=SASL_PLAINTEXT \
  -X sasl.mechanism=SCRAM-SHA-512 \
  -X sasl.username=dante-kafka-user \
  -X sasl.password=qBD7sXygrJWuAfAZls8Uyr4qo26wPI9k \
  -P -t dante-topic

$  kcat -b localhost:9094 \
  -X security.protocol=SASL_PLAINTEXT \
  -X sasl.mechanism=SCRAM-SHA-512 \
  -X sasl.username=dante-kafka-user \
  -X sasl.password=qBD7sXygrJWuAfAZls8Uyr4qo26wPI9k \
  -C -t dante-topic -o beginning
% Reached end of topic dante-topic [0] at offset 0
world
Hello from kcat
% Reached end of topic dante-topic [3] at offset 0
new world1
% Reached end of topic dante-topic [5] at offset 0
% Reached end of topic dante-topic [6] at offset 0
new hello1
Hello
% Reached end of topic dante-topic [9] at offset 0
% Reached end of topic dante-topic [1] at offset 1
% Reached end of topic dante-topic [2] at offset 1
% Reached end of topic dante-topic [4] at offset 1
% Reached end of topic dante-topic [7] at offset 1
% Reached end of topic dante-topic [8] at offset 1
^C
```

### Advanced: replication, etc.

## :white_check_mark: Monitoring

:::note Official example 
https://github.com/strimzi/strimzi-kafka-operator/blob/main/packaging/examples/metrics/kafka-metrics.yaml
:::

:::note Grafana Dashboards
https://github.com/strimzi/strimzi-kafka-operator/tree/main/packaging/examples/metrics/grafana-dashboards

Can be enabled in values:
```yaml
strimzi-kafka-operator:
  dashboards:
    enabled: true
    namespace: kafka
```
:::

- add `ConfigMap` with metrics 

[Source](https://github.com/strimzi/strimzi-kafka-operator/blob/main/packaging/examples/metrics/kafka-metrics.yaml)

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: kafka-metrics
  labels:
    app: strimzi
data:
  kafka-metrics-config.yml: |
    # See https://github.com/prometheus/jmx_exporter for more info about JMX Prometheus Exporter metrics
    lowercaseOutputName: true
    rules:
    # Special cases and very specific rules
    - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
      name: kafka_server_$1_$2
      type: GAUGE
      labels:
        clientId: "$3"
        topic: "$4"
        partition: "$5"
    - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
      name: kafka_server_$1_$2
      type: GAUGE
      labels:
        clientId: "$3"
        broker: "$4:$5"
    - pattern: kafka.server<type=(.+), cipher=(.+), protocol=(.+), listener=(.+), networkProcessor=(.+)><>connections
      name: kafka_server_$1_connections_tls_info
      type: GAUGE
      labels:
        cipher: "$2"
        protocol: "$3"
        listener: "$4"
        networkProcessor: "$5"
    - pattern: kafka.server<type=(.+), clientSoftwareName=(.+), clientSoftwareVersion=(.+), listener=(.+), networkProcessor=(.+)><>connections
      name: kafka_server_$1_connections_software
      type: GAUGE
      labels:
        clientSoftwareName: "$2"
        clientSoftwareVersion: "$3"
        listener: "$4"
        networkProcessor: "$5"
    - pattern: "kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+-total):"
      name: kafka_server_$1_$4
      type: COUNTER
      labels:
        listener: "$2"
        networkProcessor: "$3"
    - pattern: "kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+):"
      name: kafka_server_$1_$4
      type: GAUGE
      labels:
        listener: "$2"
        networkProcessor: "$3"
    - pattern: kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+-total)
      name: kafka_server_$1_$4
      type: COUNTER
      labels:
        listener: "$2"
        networkProcessor: "$3"
    - pattern: kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+)
      name: kafka_server_$1_$4
      type: GAUGE
      labels:
        listener: "$2"
        networkProcessor: "$3"
    # Some percent metrics use MeanRate attribute
    # Ex) kafka.server<type=(KafkaRequestHandlerPool), name=(RequestHandlerAvgIdlePercent)><>MeanRate
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>MeanRate
      name: kafka_$1_$2_$3_percent
      type: GAUGE
    # Generic gauges for percents
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>Value
      name: kafka_$1_$2_$3_percent
      type: GAUGE
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*, (.+)=(.+)><>Value
      name: kafka_$1_$2_$3_percent
      type: GAUGE
      labels:
        "$4": "$5"
    # Generic per-second counters with 0-2 key/value pairs
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
    # Generic gauges with 0-2 key/value pairs
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
    # Emulate Prometheus 'Summary' metrics for the exported 'Histogram's.
    # Note that these are missing the '_sum' metric!
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        "$6": "$7"
        quantile: "0.$8"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        quantile: "0.$6"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        quantile: "0.$4"
    # KRaft overall related metrics
    # distinguish between always increasing COUNTER (total and max) and variable GAUGE (all others) metrics
    - pattern: "kafka.server<type=raft-metrics><>(.+-total|.+-max):"
      name: kafka_server_raftmetrics_$1
      type: COUNTER
    - pattern: "kafka.server<type=raft-metrics><>(current-state): (.+)"
      name: kafka_server_raftmetrics_$1
      value: 1
      type: UNTYPED
      labels:
        $1: "$2"
    - pattern: "kafka.server<type=raft-metrics><>(.+):"
      name: kafka_server_raftmetrics_$1
      type: GAUGE
    # KRaft "low level" channels related metrics
    # distinguish between always increasing COUNTER (total and max) and variable GAUGE (all others) metrics
    - pattern: "kafka.server<type=raft-channel-metrics><>(.+-total|.+-max):"
      name: kafka_server_raftchannelmetrics_$1
      type: COUNTER
    - pattern: "kafka.server<type=raft-channel-metrics><>(.+):"
      name: kafka_server_raftchannelmetrics_$1
      type: GAUGE
    # Broker metrics related to fetching metadata topic records in KRaft mode
    - pattern: "kafka.server<type=broker-metadata-metrics><>(.+):"
      name: kafka_server_brokermetadatametrics_$1
      type: GAUGE
```

- enable metrics in `Kafka` resource

[Source](https://github.com/strimzi/strimzi-kafka-operator/blob/main/packaging/examples/metrics/kafka-metrics.yaml)

```yaml
spec:
  kafka:
    metricsConfig:
      type: jmxPrometheusExporter
      valueFrom:
        configMapKeyRef:
          name: kafka-metrics
          key: kafka-metrics-config.yml
  kafkaExporter:
    topicRegex: ".*"
    groupRegex: ".*"
```

- setup `PodMonitors``

[Source](https://github.com/strimzi/strimzi-kafka-operator/blob/main/packaging/examples/metrics/prometheus-install/strimzi-pod-monitor.yaml)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: cluster-operator-metrics
  labels:
    app: strimzi
spec:
  selector:
    matchLabels:
      strimzi.io/kind: cluster-operator
  namespaceSelector:
    matchNames:
      - myproject
  podMetricsEndpoints:
  - path: /metrics
    port: http
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: entity-operator-metrics
  labels:
    app: strimzi
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: entity-operator
  namespaceSelector:
    matchNames:
      - myproject
  podMetricsEndpoints:
  - path: /metrics
    port: healthcheck
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: bridge-metrics
  labels:
    app: strimzi
spec:
  selector:
    matchLabels:
      strimzi.io/kind: KafkaBridge
  namespaceSelector:
    matchNames:
      - myproject
  podMetricsEndpoints:
  - path: /metrics
    port: rest-api
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: kafka-resources-metrics
  labels:
    app: strimzi
spec:
  selector:
    matchExpressions:
      - key: "strimzi.io/kind"
        operator: In
        values: ["Kafka", "KafkaConnect", "KafkaMirrorMaker2"]
  namespaceSelector:
    matchNames:
      - myproject
  podMetricsEndpoints:
  - path: /metrics
    port: tcp-prometheus
    relabelings:
    - separator: ;
      regex: __meta_kubernetes_pod_label_(strimzi_io_.+)
      replacement: $1
      action: labelmap
    - sourceLabels: [__meta_kubernetes_namespace]
      separator: ;
      regex: (.*)
      targetLabel: namespace
      replacement: $1
      action: replace
    - sourceLabels: [__meta_kubernetes_pod_name]
      separator: ;
      regex: (.*)
      targetLabel: kubernetes_pod_name
      replacement: $1
      action: replace
    - sourceLabels: [__meta_kubernetes_pod_node_name]
      separator: ;
      regex: (.*)
      targetLabel: node_name
      replacement: $1
      action: replace
    - sourceLabels: [__meta_kubernetes_pod_host_ip]
      separator: ;
      regex: (.*)
      targetLabel: node_ip
      replacement: $1
      action: replace
```

- setup `PrometheusRules` for alerting

[Source](https://github.com/strimzi/strimzi-kafka-operator/blob/main/packaging/examples/metrics/prometheus-install/prometheus-rules.yaml)
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
    app: strimzi
  name: prometheus-k8s-rules
spec:
  groups:
  - name: kafka
    rules:
    - alert: KafkaRunningOutOfSpace
      expr: kubelet_volume_stats_available_bytes{persistentvolumeclaim=~"data(-[0-9]+)?-(.+)-kafka-[0-9]+"} * 100 / kubelet_volume_stats_capacity_bytes{persistentvolumeclaim=~"data(-[0-9]+)?-(.+)-kafka-[0-9]+"} < 15
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka is running out of free disk space'
        description: 'There are only {{ $value }} percent available at {{ $labels.persistentvolumeclaim }} PVC'
    - alert: UnderReplicatedPartitions
      expr: kafka_server_replicamanager_underreplicatedpartitions > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka under replicated partitions'
        description: 'There are {{ $value }} under replicated partitions on {{ $labels.kubernetes_pod_name }}'
    - alert: AbnormalControllerState
      expr: sum(kafka_controller_kafkacontroller_activecontrollercount) by (strimzi_io_name) != 1
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka abnormal controller state'
        description: 'There are {{ $value }} active controllers in the cluster'
    - alert: OfflinePartitions
      expr: sum(kafka_controller_kafkacontroller_offlinepartitionscount) > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka offline partitions'
        description: 'One or more partitions have no leader'
    - alert: UnderMinIsrPartitionCount
      expr: kafka_server_replicamanager_underminisrpartitioncount > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka under min ISR partitions'
        description: 'There are {{ $value }} partitions under the min ISR on {{ $labels.kubernetes_pod_name }}'
    - alert: OfflineLogDirectoryCount
      expr: kafka_log_logmanager_offlinelogdirectorycount > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka offline log directories'
        description: 'There are {{ $value }} offline log directories on {{ $labels.kubernetes_pod_name }}'
    - alert: ScrapeProblem
      expr: up{kubernetes_namespace!~"openshift-.+",kubernetes_pod_name=~".+-kafka-[0-9]+"} == 0
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'Prometheus unable to scrape metrics from {{ $labels.kubernetes_pod_name }}/{{ $labels.instance }}'
        description: 'Prometheus was unable to scrape metrics from {{ $labels.kubernetes_pod_name }}/{{ $labels.instance }} for more than 3 minutes'
    - alert: ClusterOperatorContainerDown
      expr: count((container_last_seen{container="strimzi-cluster-operator"} > (time() - 90))) < 1 or absent(container_last_seen{container="strimzi-cluster-operator"})
      for: 1m
      labels:
        severity: major
      annotations:
        summary: 'Cluster Operator down'
        description: 'The Cluster Operator has been down for longer than 90 seconds'
    - alert: KafkaBrokerContainersDown
      expr: absent(container_last_seen{container="kafka",pod=~".+-kafka-[0-9]+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'All `kafka` containers down or in CrashLookBackOff status'
        description: 'All `kafka` containers have been down or in CrashLookBackOff status for 3 minutes'
    - alert: KafkaContainerRestartedInTheLast5Minutes
      expr: count(count_over_time(container_last_seen{container="kafka"}[5m])) > 2 * count(container_last_seen{container="kafka",pod=~".+-kafka-[0-9]+"})
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: 'One or more Kafka containers restarted too often'
        description: 'One or more Kafka containers were restarted too often within the last 5 minutes'
  - name: entityOperator
    rules:
    - alert: TopicOperatorContainerDown
      expr: absent(container_last_seen{container="topic-operator",pod=~".+-entity-operator-.+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'Container topic-operator in Entity Operator pod down or in CrashLookBackOff status'
        description: 'Container topic-operator in Entity Operator pod has been or in CrashLookBackOff status for 3 minutes'
    - alert: UserOperatorContainerDown
      expr: absent(container_last_seen{container="user-operator",pod=~".+-entity-operator-.+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'Container user-operator in Entity Operator pod down or in CrashLookBackOff status'
        description: 'Container user-operator in Entity Operator pod have been down or in CrashLookBackOff status for 3 minutes'
  - name: connect
    rules:
    - alert: ConnectContainersDown
      expr: absent(container_last_seen{container=~".+-connect",pod=~".+-connect-.+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'All Kafka Connect containers down or in CrashLookBackOff status'
        description: 'All Kafka Connect containers have been down or in CrashLookBackOff status for 3 minutes'
    - alert: ConnectFailedConnector
      expr: sum(kafka_connect_connector_status{status="failed"}) > 0
      for: 5m
      labels:
        severity: major
      annotations:
        summary: 'Kafka Connect Connector Failure'
        description: 'One or more connectors have been in failed state for 5 minutes,'
    - alert: ConnectFailedTask
      expr: sum(kafka_connect_worker_connector_failed_task_count) > 0
      for: 5m
      labels:
        severity: major
      annotations:
        summary: 'Kafka Connect Task Failure'
        description: 'One or more tasks have been in failed state for 5 minutes.'
  - name: bridge
    rules:
    - alert: BridgeContainersDown
      expr: absent(container_last_seen{container=~".+-bridge",pod=~".+-bridge-.+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'All Kafka Bridge containers down or in CrashLookBackOff status'
        description: 'All Kafka Bridge containers have been down or in CrashLookBackOff status for 3 minutes'
    - alert: AvgProducerLatency
      expr: strimzi_bridge_kafka_producer_request_latency_avg > 10
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka Bridge producer average request latency'
        description: 'The average producer request latency is {{ $value }} on {{ $labels.clientId }}'
    - alert: AvgConsumerFetchLatency
      expr: strimzi_bridge_kafka_consumer_fetch_latency_avg > 500
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka Bridge consumer average fetch latency'
        description: 'The average consumer fetch latency is {{ $value }} on {{ $labels.clientId }}'
    - alert: AvgConsumerCommitLatency
      expr: strimzi_bridge_kafka_consumer_commit_latency_avg > 200
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka Bridge consumer average commit latency'
        description: 'The average consumer commit latency is {{ $value }} on {{ $labels.clientId }}'
    - alert: Http4xxErrorRate
      expr: strimzi_bridge_http_server_requestCount_total{code=~"^4..$", container=~"^.+-bridge", path !="/favicon.ico"} > 10
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: 'Kafka Bridge returns code 4xx too often'
        description: 'Kafka Bridge returns code 4xx too much ({{ $value }}) for the path {{ $labels.path }}'
    - alert: Http5xxErrorRate
      expr: strimzi_bridge_http_server_requestCount_total{code=~"^5..$", container=~"^.+-bridge"} > 10
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: 'Kafka Bridge returns code 5xx too often'
        description: 'Kafka Bridge returns code 5xx too much ({{ $value }}) for the path {{ $labels.path }}'
  - name: mirrorMaker2
    rules:
    - alert: MirrorMaker2ContainerDown
      expr: absent(container_last_seen{container=~".+-mirrormaker2",pod=~".+-mirrormaker2-.+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'All Kafka Mirror Maker 2 containers down or in CrashLookBackOff status'
        description: 'All Kafka Mirror Maker 2 containers have been down or in CrashLookBackOff status for 3 minutes'
  - name: kafkaExporter
    rules:
    - alert: UnderReplicatedPartition
      expr: kafka_topic_partition_under_replicated_partition > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Topic has under-replicated partitions'
        description: 'Topic  {{ $labels.topic }} has {{ $value }} under-replicated partition {{ $labels.partition }}'
    - alert: TooLargeConsumerGroupLag
      expr: kafka_consumergroup_lag > 1000
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Consumer group lag is too big'
        description: 'Consumer group {{ $labels.consumergroup}} lag is too big ({{ $value }}) on topic {{ $labels.topic }}/partition {{ $labels.partition }}'
    - alert: NoMessageForTooLong
      expr: changes(kafka_topic_partition_current_offset[10m]) == 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'No message for 10 minutes'
        description: 'There is no messages in topic {{ $labels.topic}}/partition {{ $labels.partition }} for 10 minutes'
  - name: certificates
    interval: 1m0s
    rules:
    - alert: CertificateExpiration
      expr: |
        strimzi_certificate_expiration_timestamp_ms/1000 - time() < 30 * 24 * 60 * 60
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: 'Certificate will expire in less than 30 days'
        description: 'Certificate of type {{ $labels.type }} in cluster {{ $labels.cluster }} in namespace {{ $labels.resource_namespace }} will expire in less than 30 days'
```

- patch `PrometheusRules` annotations with escape brackets to avoid helm template conflicts

```bash
gsed -Ei 's/^([[:space:]]*description:[[:space:]]*)(["'\''])(.*)\2/\1"{{\` \3 \`}}"/' apps-common/strimzi/templates/prometheusrules.yaml
gsed -Ei 's/^([[:space:]]*summary:[[:space:]]*)(["'\''])(.*)\2/\1"{{\` \3 \`}}"/' apps-common/strimzi/templates/prometheusrules.yaml
# also manualy remove ` character from annotations
```

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Zookeeper vs KRaft](#)

