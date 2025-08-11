# Monitoring stack

||Self-hosted|SaaS|
|-|-|-|
|**Tool**|[kube-prometheus-stack](#)|[Datadog](#)|
|**Type**|||
|**Deploy**|[helm-chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)||

**kube-prometheus-stack:**

||Engine|Dashboards|Alerts|
|-|-|-|-|
|**Tool**|[Prometheus](prometheus.md)|[Grafana](grafana.md)|[Alert Manager](alertmanager.md)|
|**Type**|kubernetes-operator|||
|**Deploy**|helm-chart|||

## Architecture

[Prometheus Stack Architecture](prometheus-stack-architecture.md)

## Monitoring

- what metrics to pay attention on
- alerts

## Patform integration

- how this tool integrated into a platform
- how to use it in a platform
- how to debug
