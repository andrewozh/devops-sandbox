---
tags:
- tool
- helm
- applibrary
- platform
- infrastructure
---

# Helm Applibrary

:::note Jsonnet / KCL / CUE
Such fancy alternatives just can't dynamically read and merge yaml configuration! This feature is required for multi-dimensional yaml configuration hierarchy. So helm is still on top imho. I'll check them out again later..
:::

## Use Applibrary

* The `_chart/` directory contains a reusable Helm library with common Kubernetes templates
* Each application uses the library as a dependency

```yaml title="Chart.yaml"
apiVersion: v2
name: vault
version: 0.1.0
dependencies:
  - name: chart
    version: 0.1.0
    repository: file://../../_chart
```

### Configuration values

📖 **[Configuration Files →](articles/config)**

---

## Articles

* [How to create new application](./articles/how-to-create-new-aplication.md)
* [How to upgrade helm chart](./articles/how-to-upgrade-helm-chart.md)
