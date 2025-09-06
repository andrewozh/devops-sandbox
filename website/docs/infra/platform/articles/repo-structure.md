---
tags:
- article
- applibrary
- platform
- infrastructure
---

# Repository Structure

:::warning This page is under construction
:::

```
devops-sandbox/
├── _argocd-infra/           # ArgoCD infrastructure and ApplicationSets
│   ├── templates/
│   │   └── appsets.yaml     # Dynamic ApplicationSet generator
│   └── values.yaml          # ArgoCD configuration
├── _chart/                  # Reusable application library (applib)
│   ├── templates/           # Common Kubernetes templates
│   └── values.yaml          # Default Library chart configuration values
├── applications/            # Individual application configurations
│   └── */
│       ├── Chart.yaml       # App-specific chart with dependencies
│       ├── argo.yaml        # ArgoCD application configuration
│       ├── values.yaml      # Application-specific values
│       └── *.values.yaml    # Environment-specific overrides
├── global.yaml              # Global configuration baseline
├── demo.yaml                # Cloud-specific overrides
└── *.yaml                   # Additional configuration files
```

