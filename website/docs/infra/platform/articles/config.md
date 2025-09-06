---
tags:
- article
- platform
- infrastructure
---

# Configuration

:::warning This page is under construction
:::

## Global Configuration Schema

The `global.yaml` file defines the baseline configuration and cluster topology:

```yaml
namespace: default              # Default namespace
repo: <git-repository-url>      # Repository URL

clouds:                         # Define your infrastructure topology
  - name: local
    accounts:
      - name: main
        environments:
          - name: common

global:                         # Default global values
  cloud: local
  account: main  
  env: common
```

## Application Configuration Schema

Each `applications/*/argo.yaml` supports:

```yaml
destination: all|<cloud>|<account>|<environment>|<combination>
namespace: <target-namespace>
autosync: true|false
syncOptions:
  - CreateNamespace=true
  - ServerSideApply=true
  # ... other ArgoCD sync options
```

This architecture provides a scalable, maintainable GitOps solution that grows with your infrastructure complexity while maintaining simplicity for individual application deployments.

## Override Hierarchy

* [Configuration Files Hierarchy](./configuration-files-hierarchy.md)
