---
tags:
- article
- platform
- infrastructure
---

# Configuration

## Global Configuration Schema

A configuration files with shared settings across all applications.

:::note 📖 **[Configuration Files Hierarchy →](configuration-files-hierarchy)**
* **Location:** root of repository
* **Main file:** `global.yaml`
* **Overrides:** `<cloud>-<account>-<environment>.yaml`
:::

The `global.yaml` file defines the baseline configuration and cluster topology:

```yaml title="global.yaml"
namespace: default              # Default namespace
repo: <git-repository-url>      # Repository URL
clouds:                         # Define infrastructure topology
  - name: local
    accounts:
      - name: main
        environments:
          - name: common
```

## Application Configuration Schema

A configuration files for specific application.

:::note 📖 **[Configuration Files Hierarchy →](configuration-files-hierarchy)**
* **Location:** application directory `applications/your-app/`
* **Main file:** `values.yaml`
* **Overrides:** `<cloud>-<account>-<environment>.values.yaml`
:::

```yaml title="applications/your-app/values.yaml"
chart:
  # put your values here
  # https://github.com/andrewozh/devops-sandbox/blob/main/_chart/values.yaml
```
