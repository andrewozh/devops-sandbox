# Apache Kafka

||Self-hosted|SaaS|
|-|-|-|
|**Tool**|[Strimzi Kafka Operator](strimzi.md)||
|**Type**|kubernetes-operator||
|**Deploy**|helm-chart||

## Architecture

- How it works
- Main terms
- Diff between self-hosted and SaaS

### Kafka

```
  +-----------+       +---------+       +-----------+
  | Producer1 | ----> |         |       |           |
  | Producer2 | ----> |  Kafka  | <---- | Consumer1 |
  |           |       |  Broker | <---- | Consumer2 |
  +-----------+       +---------+       +-----------+
                           |
                           v
                      +----------+
                      | Topic A  |
                      +----------+
                      |Partition0|
                      |Partition1|
                      +----------+
```

**Cluster** -- made up of multiple **brokers**, which work together to provide scalability and fault tolerance.

**Broker** -- A Kafka server that stores data and serves clients. Each broker handles some partitions.

**Topic** -- A named category where messages are stored.

**Partition** -- Each topic is split into partitions for scalability and parallelism. Each partition is an ordered, immutable sequence of messages.

**Replication Factor** -- determines how many copies of each partition exist in the cluster. A replication factor of 3 is typical, ensuring that the data survives the failure of up to two brokers.

**Leader** -- each topic partition, have one leader broker to assign replication of topic partitions to the follower brokers.

**Follower** -- the rest of brokers that is not a leader for a partition. They replicate the data from the leader broker.

**Producer** -- Sends data (messages) to a specific topic using a **partition key**, which determines which partition the message will go to.

**Consumer** -- Reads messages from a topic. Consumers can be grouped into Consumer Groups for load balancing.

**Consumer Group** -- A group of consumers that share the work of reading from a topic. Each partition is read by only one consumer in the group.

**Offset** -- unique identifiers assigned to each record within a partition. They help consumers keep track of the messages they have read, ensuring that they can resume processing from where they left off in case of a failure.

### Zookeeper

Used to manage Kafka brokers (now optional with KRaft mode).

### KRaft

## Monitoring

- what metrics to pay attention on
- alerts

## Patform integration

- how this tool integrated into a platform
- how to use it in a platform
- how to debug
