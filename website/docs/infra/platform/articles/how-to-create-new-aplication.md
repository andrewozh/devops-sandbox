---
tags:
- article
- argocd
- platform
- infrastructure
---

# How to create new application

:::warning This page is under construction
:::

## Adding a New Application

1. **Create application directory:**

```bash
mkdir applications/my-new-app
```

2. **Define Helm chart:**

```yaml
# applications/my-new-app/Chart.yaml
apiVersion: v2
name: my-new-app
version: 0.1.0
dependencies:
  - name: chart
    version: 0.1.0
    repository: file://../../_chart
```

3. **Configure ArgoCD behavior:**

```yaml
# applications/my-new-app/argo.yaml
destination: all
namespace: my-app-namespace
autosync: true
```

4. **Set application values:**

```yaml
# applications/my-new-app/values.yaml
chart:
  image: my-app:latest
  port: 8080
```

5. **Commit and push** - ArgoCD will automatically discover and deploy!


