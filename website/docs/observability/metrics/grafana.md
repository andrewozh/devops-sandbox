# Grafana

|**Distro**|[Grafana](https://grafana.com)|
|-|-|
|**Type**|deployment|
|**Deploy**|helm-chart|
|**Docs**|[link](https://grafana.com/docs/grafana/latest/)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|web|

## Setup

```yaml
  grafana:
    defaultDashboardsEnabled: false
    serviceMonitor:
      enabled: false
```

## Usecases

### :white_check_mark: Basic: add dashboards

- search dashboard https://grafana.com/grafana/dashboards/

- download JSON and put it into `kube-prometheus-stack/dashboards/` directory

- template automatically put it in grafana as configmap with special label `grafana_dashboard: "1"`

```yaml
{{ range $path, $_ :=  .Files.Glob  "dashboards/**.json" }}
{{ $name := $path | trimPrefix "dashboards/" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: monitoring
  name: dashboard-{{ $name | trimSuffix ".json" }}
  labels:
    grafana_dashboard: "1"
  annotations:
    argocd.argoproj.io/sync-options: ServerSideApply=true
data:
  {{ $name }}: |
{{ $.Files.Get $path | nindent 4 }}
{{ end }}
```

### Common: manage dashboards

## :white_check_mark: Monitoring

:::note Grafana Dashboard
https://grafana.com/grafana/dashboards/22064-internal-grafana-stats/
:::

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Prometheus Stack Architecture](prometheus-stack-architecture.md)
* [Grafana Dashboard patcher](grafana-dashboard-patcher.md)
