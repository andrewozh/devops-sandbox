# Prometheus

|**Distro**|[Prometheus](https://prometheus.io)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](https://prometheus.io/docs/introduction/overview/)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|web|

## Setup

This allows Prometheus to monitor resources created outside of the kube-prometheus-stack installation.

```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      ruleSelectorNilUsesHelmValues: false
      serviceMonitorSelectorNilUsesHelmValues: false
      podMonitorSelectorNilUsesHelmValues: false
      probeSelectorNilUsesHelmValues: false
```

## Usecases

### :white_check_mark: Basic: kube-state-metrics, node-exporter

* kube-state-metrics

```yaml
  kube-state-metrics:
    fullnameOverride: "kube-state-metrics"
    releaseLabel: true
    prometheus:
      monitor:
        enabled: true
        honorLabels: true
        metricRelabelings:
          - action: drop
            regex: kube_pod_tolerations
            sourceLabels:
              - __name__
          - action: drop
            regex: kubernetes_feature_enabled
            sourceLabels:
              - __name__
          - action: drop
            regex: kube_pod_status_reason
            sourceLabels:
              - __name__
          - action: labeldrop
            regex: uid
          - action: drop
            regex: kube_pod_status_qos_class
            sourceLabels:
              - __name__
          - action: drop
            regex: kube_pod_status_ready
            sourceLabels:
              - __name__
          - action: drop
            regex: kube_pod_status_scheduled
            sourceLabels:
              - __name__

    metricLabelsAllowlist:
      - pods=[*]
      - cronjobs=[*]
      - jobs=[*]
      - deployments=[*]
      - statefulsets=[*]
      - nodes=[*]
```

* node-exporter

```yaml
  prometheus-node-exporter:
    extraArgs:
      - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)
      - --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$
      - --no-collector.arp
      - --no-collector.bcache
      - --no-collector.bonding
      - --no-collector.btrfs
      - --no-collector.dmi
      - --no-collector.fibrechannel
      - --no-collector.hwmon
      - --no-collector.infiniband
      - --no-collector.ipvs
      - --no-collector.nfs
      - --no-collector.rapl
      - --no-collector.sockstat
      - --no-collector.softnet
      - --no-collector.tapestats
      - --no-collector.textfile
      - --no-collector.thermal_zone
      - --no-collector.xfs
      - --no-collector.zfs
```

### Common:

## :white_check_mark: Monitoring

Self-created grafana dashboard can be found in the [kube-prometheus-stack/dashboards](https://github.com/andrewozh/devops-sandbox/blob/main/apps-common/kube-prometheus-stack/dashboards/prometheus.json)

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Prometheus Stack Architecture](prometheus-stack-architecture.md#prometheus-server)
