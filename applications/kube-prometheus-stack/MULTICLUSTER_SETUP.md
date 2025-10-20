# Multicluster Monitoring Setup Guide

## Architecture Overview

This setup implements centralized monitoring with:
- **Common Cluster**: Central Prometheus + Grafana + Alertmanager
- **Stage Cluster**: Agent mode Prometheus (metrics collection only)
- **Cross-cluster communication**: Via Istio east-west gateway

## Configuration Files

1. **`local-common.values.yaml`**: Full monitoring stack for common cluster
   - Enables remote write receiver
   - Configures multicluster Grafana dashboards
   - Sets cluster labels

2. **`local-stage.values.yaml`**: Agent mode for stage cluster
   - Disables Grafana and Alertmanager
   - Configures remote write to common cluster
   - Keeps only metric collectors

3. **`templates/monitoring-gateway.yaml`**: Istio networking resources
   - **Common cluster**: Gateway + VirtualService (expose Prometheus)
   - **Stage cluster**: ServiceEntry + DestinationRule (reach common cluster)

## Implementation Steps

### 1. Update Common Cluster
```bash
# Switch to common cluster context
kubectl config use-context kind-common

# Update monitoring stack to central mode
# (Update ArgoCD application to use local-common.values.yaml)
```

### 2. Update Stage Cluster  
```bash
# Switch to stage cluster context
kubectl config use-context kind-stage

# Update monitoring stack to agent mode
# (Update ArgoCD application to use local-stage.values.yaml)
```

### 3. Verify Cross-cluster Communication
```bash
# Check Istio gateway in common cluster
kubectl get gateway -n istio-system prometheus-multicluster-gateway

# Check ServiceEntry in stage cluster
kubectl get serviceentry -n monitoring prometheus-common-cluster

# Check remote write status in stage cluster
kubectl logs -n monitoring prometheus-kube-prometheus-stack-prometheus-0 | grep "remote_write"
```

### 4. Verify Metrics Collection
```bash
# Access Grafana in common cluster
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Query metrics with cluster labels:
# up{cluster="common"}
# up{cluster="stage"}
```

## Key Features

✅ **Centralized Dashboards**: Single Grafana showing all clusters  
✅ **Resource Efficiency**: ~50% reduction in monitoring footprint  
✅ **Secure Communication**: Leverages existing Istio mTLS  
✅ **Cluster Identification**: All metrics labeled with cluster name  
✅ **Scalable**: Easy to add more clusters

## Network Flow

```
Stage Cluster                    Common Cluster
┌─────────────────┐             ┌─────────────────┐
│ Prometheus      │             │ Istio Gateway   │
│ (Agent Mode)    │ ───────────▶│ :15090          │
│                 │   Remote     │                 │
│ • Scrape local  │   Write      │ ┌─────────────┐ │
│ • Forward all   │   Metrics    │ │ Prometheus  │ │
│                 │             │ │ (Central)   │ │
└─────────────────┘             │ └─────────────┘ │
                                │                 │
                                │ ┌─────────────┐ │
                                │ │ Grafana     │ │
                                │ │ (Unified)   │ │
                                │ └─────────────┘ │
                                └─────────────────┘
```

## Troubleshooting

### Remote Write Issues
```bash
# Check connectivity from stage to common
kubectl exec -n monitoring prometheus-kube-prometheus-stack-prometheus-0 -- \
  curl -v http://prometheus-common.local:15090/api/v1/write

# Check Istio proxy logs
kubectl logs -n monitoring prometheus-kube-prometheus-stack-prometheus-0 -c istio-proxy
```

### Missing Metrics
- Verify cluster labels are applied correctly
- Check service monitors and relabeling configs
- Ensure Istio sidecar injection is enabled