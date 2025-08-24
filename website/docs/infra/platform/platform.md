# GitOps Platform

This repository implements a sophisticated GitOps architecture using ArgoCD with multi-dimensional configuration management across clouds, accounts, and environments.

## 🏗️ Architecture Overview

```
Main ArgoCD Application
    ↓
ApplicationSets (per cloud/account/environment combination)  
    ↓
Individual Argo Applications
    ↓
Helm Charts + Application Library + Configuration Hierarchy
```

## 📁 Repository Structure

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

## 🔄 Configuration Flow

### 1. Main ArgoCD Application → ApplicationSets

The main ArgoCD application deploys ApplicationSets that dynamically discover and manage all applications in the repository.

**Key File:** `_argocd-infra/templates/appsets.yaml`

```yaml
# Creates ApplicationSets for each cloud/account/environment combination
{{- range $cloud := .Values.clouds }}
{{- range $account := $cloud.accounts }}
{{- range $environment := $account.environments }}
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: "{{ $cloud.name }}-{{ $account.name }}-{{ $environment.name }}"
```

### 2. ApplicationSets → Individual Applications

Each ApplicationSet uses a matrix generator to:

- **Discover applications** via Git file generator (`applications/*/argo.yaml`)
- **Select target clusters** based on destination matching
- **Generate ArgoCD Applications** for each app/cluster combination

**Discovery Pattern:**
```yaml
generators:
- matrix:
    generators:
    - git:
        repoURL: {{ $.Values.repo }}
        files:
          - path: 'applications/*/argo.yaml'  # Auto-discover apps
    - clusters: {}                           # Match with clusters
```

**Cluster Selection Logic:**

```yaml
selector:
  matchExpressions:
  - key: destination
    operator: In
    values:
    - "all"                                    # Deploy everywhere
    - "{{ $cloud.name }}"                     # Cloud-specific
    - "{{ $account.name }}"                   # Account-specific  
    - "{{ $environment.name }}"               # Environment-specific
    - "{{ $cloud.name }}-{{ $account.name }}" # Combined targeting
```

### 3. Application Configuration Pattern

Each application follows a standardized structure:

**Application Directory:**

```
applications/kube-prometheus-stack/
├── Chart.yaml      # Helm chart with dependencies
├── argo.yaml       # ArgoCD-specific configuration  
├── values.yaml     # Base application values
└── *.values.yaml   # Environment-specific overrides
```

**argo.yaml Configuration:**

```yaml
destination: all              # Where to deploy (cluster selector)
namespace: monitoring         # Target namespace
autosync: true               # Enable automatic synchronization
syncOptions:                 # ArgoCD sync behavior
  - ServerSideApply=true
  - CreateNamespace=true
```

## 🎯 Helm Chart + Application Library Pattern

### Application Library (`_chart/`)

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

### Application Chart Pattern

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

## 📊 Configuration Hierarchy & Values Override

The system implements a sophisticated configuration hierarchy with multiple override levels:

### Configuration Files Priority (High to Low)

```yaml
# ApplicationSet automatically includes these value files:
valueFiles:
  # 1. Global baseline
  - /global.yaml
  
  # 2. Cloud-specific  
  - '/{{ $cloud.name }}.yaml'           # e.g., /demo.yaml
  
  # 3. Account-specific
  - '/{{ $account.name }}.yaml'         # e.g., /main.yaml
  
  # 4. Environment-specific  
  - '/{{ $environment.name }}.yaml'     # e.g., /common.yaml
  
  # 5. Combined configurations
  - '/{{ $cloud.name }}-{{ $account.name }}.yaml'
  - '/{{ $cloud.name }}-{{ $environment.name }}.yaml' 
  - '/{{ $account.name }}-{{ $environment.name }}.yaml'
  - '/{{ $cloud.name }}-{{ $account.name }}-{{ $environment.name }}.yaml'
  
  # 6. Application-specific (in app directory)
  - values.yaml                        # Base app values
  - {{ $cloud.name }}.values.yaml     # App cloud overrides
  - {{ $account.name }}.values.yaml   # App account overrides
  - {{ $environment.name }}.values.yaml # App env overrides
  # ... (same pattern for combined app-specific values)
```

### Example Configuration Merge

**global.yaml** (baseline):
```yaml
namespace: default
repo: https://github.com/andrewozh/devops-sandbox.git
global:
  cloud: local
  account: main
  env: common
```

**demo.yaml** (cloud override):
```yaml
repo: git://git-server.default.svc.cluster.local/
global:
  cloud: local
  account: killercoda
  env: demo
```

**Final merged configuration:**
```yaml
namespace: default
repo: git://git-server.default.svc.cluster.local/  # Overridden by demo.yaml
global:
  cloud: local
  account: killercoda  # Overridden by demo.yaml  
  env: demo           # Overridden by demo.yaml
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

## 🔧 Adding a New Application

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

## 📋 Configuration Reference

### Global Configuration Schema

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

### Application Configuration Schema

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

---

## ArgoCD

- argocd appset schema
- how to setup argocd

- [?] Split applications (charts) and releases
  we have a single directory for apps (charts)
  and we have a separate directory for releases
  each release refers to a chart
  also each release keep current values folder structure for sophisticated overrides

## App-library

* [App-library Helm chart](./applibrary-helm-chart.md)

---

## Other manifest generation tools: KCL / Jsonnet

:::warning Jsonnet
Do not allow to dynamically read yaml configuration
Required for global yaml configuration hierarchy
:::

:::warning KCL
Do not allow to dynamically read yaml configuration
Required for global yaml configuration hierarchy
:::


