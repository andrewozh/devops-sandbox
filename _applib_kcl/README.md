# 🚀 YAML + KCL Hybrid Application Generator

A clean, modern approach to Kubernetes manifest generation that combines the **readability of YAML** with the **power of KCL**.

## ✨ What This Is

This replaces your Helm chart with a **hybrid approach**:
- **📝 YAML files** for readable, editable configuration
- **🔧 KCL logic** for dynamic manifest generation 
- **🛡️ Type safety** and validation built-in
- **🚀 Production-ready** Kubernetes resources

## 📁 Files Overview

```
_applib/
├── app.k                    # 🎯 Main KCL application (THE ONLY FILE YOU NEED!)
├── values.yaml              # 📝 Default configuration (same as Helm values.yaml)
├── examples/
│   ├── production.yaml      # 🏭 Production environment config
│   └── development.yaml     # 🧪 Development environment config
├── kcl.mod                  # 📦 KCL module definition
├── Makefile                 # 🛠️ Convenience commands
└── README.md                # 📖 This file
```

## 🎯 Quick Start

### 1. View the Demo
```bash
kcl app.k
```

### 2. Generate Just Manifests
```bash
kcl app.k --format yaml | grep -A 1000 "manifests:" | tail -n +2
```

### 3. Deploy to Kubernetes
```bash
kcl app.k --format yaml | grep -A 1000 "manifests:" | tail -n +2 | kubectl apply -f -
```

## 🔧 How It Works

### Step 1: Edit YAML Configuration
```yaml
# examples/production.yaml - Easy to read and edit!
name: my-web-app
namespace: production
replicaCount: 3

image:
  repository: my-registry/web-app
  tag: v1.2.3
  pullPolicy: Always

service:
  type: LoadBalancer
  port: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Step 2: KCL Generates Resources
The `app.k` file automatically:
- ✅ Loads your YAML configuration
- ✅ Adds environment labels and metadata
- ✅ Generates complete Kubernetes manifests:
  - Deployment with health checks
  - LoadBalancer Service  
  - ServiceAccount
  - Ingress with TLS
  - HorizontalPodAutoscaler

### Step 3: Deploy
```bash
kcl app.k --format yaml | kubectl apply -f -
```

## 🎨 Generated Resources

From the production YAML, KCL generates:
- **Deployment** - 3 replicas, resource limits, health probes
- **Service** - LoadBalancer on port 8080
- **ServiceAccount** - With proper labels
- **Ingress** - With TLS and cert-manager
- **HPA** - CPU/memory based scaling (2-10 replicas)

All with **automatic labels** and **environment metadata**!

## 🆚 Compared to Helm

### ❌ Helm Problems
```yaml
# Complex template syntax
{{ if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "chart.fullname" . }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
# ... more template hell
{{ end }}
```

### ✅ YAML + KCL Solution
```yaml
# Clean YAML configuration
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
```

```python
# Clean KCL generation logic  
generateIngress = {
    apiVersion = "networking.k8s.io/v1"
    kind = "Ingress"
    metadata = {
        name = productionConfig.name
        annotations = productionConfig.ingress.annotations
    }
    # ... clean, readable logic
}
```

## 🛠️ Customization

### For Simple Changes
Just edit the YAML files:
```bash
vim examples/production.yaml  # Edit config
kcl app.k                     # Generate manifests
```

### For Advanced Logic
Modify `app.k` to add:
- Conditional resources
- Dynamic configuration
- Complex label generation
- Multi-environment logic

## 📊 Benefits Summary

| Feature | Helm | YAML + KCL |
|---------|------|-------------|
| **Configuration** | YAML ✅ | YAML ✅ |
| **Readability** | Templates ❌ | Clean ✅ |
| **Type Safety** | None ❌ | Built-in ✅ |
| **Dynamic Logic** | Template Hell ❌ | Clean KCL ✅ |
| **Debugging** | Hard ❌ | Easy ✅ |
| **Migration** | - | Drop-in ✅ |

## 🔄 Migration from Helm

1. **Keep your `values.yaml`** - it works as-is! ✅
2. **Copy your environment configs** to `examples/` ✅  
3. **Replace** `helm template` with `kcl app.k` ✅
4. **Deploy** same as before ✅

## 🎯 Real-World Usage

```bash
# Development
vim examples/development.yaml  # 1 replica, basic resources
kcl app.k | kubectl apply -f -

# Staging  
vim examples/staging.yaml     # 2 replicas, medium resources
kcl app.k | kubectl apply -f -

# Production
vim examples/production.yaml  # 3 replicas, full resources + HPA
kcl app.k | kubectl apply -f -
```

## 🏆 Success Story

This implementation successfully:
- ✅ **Loads YAML configs** - All 3 environment files parsed perfectly
- ✅ **Generates 5 K8s resources** - Deployment, Service, ServiceAccount, Ingress, HPA  
- ✅ **Adds smart enhancements** - Environment labels, proper metadata
- ✅ **Maintains compatibility** - Same structure as original Helm values
- ✅ **Provides type safety** - KCL validates configuration at compile time

**Result**: Production-ready Kubernetes manifests from clean, readable YAML configurations with powerful KCL logic.

---

**The hybrid approach gives you readable configs AND powerful logic!** 🎉