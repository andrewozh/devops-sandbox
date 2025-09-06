---
tags:
- tool
- argocd
- platform
- infrastructure
---

# ArgoCD

## Main ArgoCD Application

The main ArgoCD application deploys ApplicationSets that dynamically discover and manage all applications in the repository.

**Key File:** `_argocd-infra/templates/appsets.yaml`

## ApplicationSets → Individual Applications

Each ApplicationSet uses a matrix generator to:

- **Discover applications** via Git file generator (`applications/*/argo.yaml`)
- **Select target clusters** based on destination matching
- **Generate ArgoCD Applications** for each app/cluster combination

## Application Configuration

Each application follows a standardized structure:

**Application Directory:**

```
applications/my-app/
├── Chart.yaml      # Helm chart with dependencies
├── argo.yaml       # ArgoCD-specific configuration
├── values.yaml     # Base application values
└── *.values.yaml   # Environment-specific overrides
```

### argo.yaml

```yaml
destination: all|<cloud>|<account>|<environment>|<combination>
namespace: <target-namespace>
autosync: true|false
syncOptions:
  - CreateNamespace=true
  - ServerSideApply=true
  # ... other ArgoCD sync options
```

---

📖 **[Helm Applibrary →](applibrary)**

