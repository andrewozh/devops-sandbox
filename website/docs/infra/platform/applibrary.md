---
tags:
- tool
- helm
- applibrary
- platform
- infrastructure
---

# Helm Applibrary

:::warning This page is under construction
:::

🎯 Helm Chart + Application Library Pattern

:::note Jsonnet / KCL / CUE
Such fancy alternatives just can't dynamically read and merge yaml configuration! This feature is required for multi-dimensional yaml configuration hierarchy. So helm is still on top imho. I'll check them out again later..
:::

## Application Library (`_chart/`)

The `_chart/` directory contains a reusable Helm library with common Kubernetes templates:

```yaml
# Chart.yaml
apiVersion: v2
name: chart
type: application           # Reusable application library
version: 0.1.0
```

**Templates Available:**

- `deployment.yaml` - Kubernetes Deployment
- `service.yaml` - Kubernetes Service  
- `ingress.yaml` - Ingress configuration
- `serviceaccount.yaml` - Service Account
- `hpa.yaml` - Horizontal Pod Autoscaler

## Application Chart Pattern

Each application uses the library as a dependency:

```yaml
# applications/*/Chart.yaml
apiVersion: v2
name: prom-stack
version: 0.1.0
dependencies:
  - name: kube-prometheus-stack      # External chart
    version: "65.1.1"
    repository: https://prometheus-community.github.io/helm-charts
  - name: chart                      # Internal app library
    version: 0.1.0
    repository: file://../../_chart  # Local dependency
```

## 🚀 Key Features

### 1. **Multi-Dimensional Targeting**
- **Cloud-level**: Different cloud providers or regions
- **Account-level**: Different organizational units or customers  
- **Environment-level**: dev, staging, production, etc.
- **Combined targeting**: Fine-grained deployment control

### 2. **Automatic Discovery**
- Applications are automatically discovered via `applications/*/argo.yaml`
- No manual ApplicationSet updates required for new applications
- Git-based source of truth

### 3. **Configuration Inheritance** 
- Global baseline with environment-specific overrides
- Helm's native value file precedence handling
- Support for both global and application-specific configuration layers

### 4. **Application Library Reuse**
- Common Kubernetes patterns in `_chart/` 
- Consistent deployment patterns across all applications
- Easy template updates affect all applications

### 5. **Flexible Deployment Control**
- Applications choose their deployment scope via `argo.yaml`
- Cluster-specific, environment-specific, or global deployments
- Fine-grained sync policy control per application

---

## Articles

* [How to create new application](./articles/how-to-create-new-aplication.md)
* [How to upgrade helm chart](./articles/how-to-upgrade-helm-chart.md)
