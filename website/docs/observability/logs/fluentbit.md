# Fluent-bit

|**Distro**|[Fluent-bit](https://fluentbit.io)|
|-|-|
|**Type**|daemonset|
|**Deploy**|helm-chart|
|**Docs**|[link](https://docs.fluentbit.io/manual)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**||

## Setup

- deployment explained
- how to setup

## Usecases

### :white_check_mark: Basic: send kubernetes pods logs to ElasticSearch

```yaml
fluent-bit:
  config:
    service: |
      [SERVICE]
          Daemon Off
          Flush {{ .Values.flush }}
          Log_Level {{ .Values.logLevel }}
          Parsers_File /fluent-bit/etc/parsers.conf
          Parsers_File /fluent-bit/etc/conf/custom_parsers.conf
          HTTP_Server On
          HTTP_Listen 0.0.0.0
          HTTP_Port {{ .Values.metricsPort }}
          Health_Check On
    inputs: |
      [INPUT]
          Name tail
          Path /var/log/containers/*.log
          Exclude_Path /var/log/containers/fluent-bit*.log
          multiline.parser docker, cri
          Tag kube.*
          Mem_Buf_Limit 5MB
          Skip_Long_Lines On
    filters: |
      [FILTER]
          Name kubernetes
          Match kube.*
          Merge_Log On
          Keep_Log Off
          K8S-Logging.Parser On
          K8S-Logging.Exclude On
          Labels Off
          Annotations Off
    outputs: |
      [OUTPUT]
          Name es
          Match kube.*
          Host {{ .Values.esHost }}
          Port {{ .Values.esPort }}
          HTTP_User fluentbit
          HTTP_Passwd fluentbit
          Logstash_Format On
          Retry_Limit False
          Suppress_Type_Name On
          TLS On
          TLS.Verify Off
    customParsers: |
      [PARSER]
          Name docker_no_time
          Format json
          Time_Keep Off
          Time_Key time
          Time_Format %Y-%m-%dT%H:%M:%S.%L

```

## :white_check_mark: Monitoring

:::note Grafana Dashboard
https://grafana.com/grafana/dashboards/7752-logging-dashboard/
:::

- enable servicemonitor

```yaml
fluent-bit:
  serviceMonitor:
    enabled: true
    namespace: monitoring
```

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Example article link](#)

