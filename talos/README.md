# Talos Dual Cluster Setup (Podman on macOS)

This directory contains configuration and scripts to run two local Talos Kubernetes clusters with cross-cluster networking and DNS resolution using Podman on macOS.

## Prerequisites

- [Talos](https://www.talos.dev/v1.8/introduction/getting-started/) installed
- [Podman](https://podman.io/getting-started/installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed

### Install Talosctl (if not already installed)

```bash
curl -sL https://talos.dev/install | sh
```

## Architecture

- **Network**: Both clusters run on a shared Podman network `talos-net` (172.20.0.0/16)
- **Cluster1**: 
  - Control plane: 127.0.0.1:6443
  - Node IP: 172.20.0.10
  - Pod CIDR: 10.244.0.0/16
  - Service CIDR: 10.96.0.0/12
  - DNS Domain: cluster1.local
- **Cluster2**:
  - Control plane: 127.0.0.1:6444
  - Node IP: 172.20.0.20
  - Pod CIDR: 10.245.0.0/16
  - Service CIDR: 10.97.0.0/12
  - DNS Domain: cluster2.local

## Quick Start

### 1. Start Both Clusters

```bash
cd talos
make clusters-up
```

This will:
- Create the Podman network
- Generate Talos configurations
- Start both clusters
- Wait for them to be ready

### 2. Get Kubeconfigs

```bash
make kubeconfigs
```

Kubeconfigs will be saved to:
- `configs/cluster1/kubeconfig`
- `configs/cluster2/kubeconfig`

### 3. Verify Clusters

```bash
# Check cluster1
KUBECONFIG=configs/cluster1/kubeconfig kubectl get nodes

# Check cluster2
KUBECONFIG=configs/cluster2/kubeconfig kubectl get nodes
```

### 4. Setup Cross-Cluster DNS (Optional)

```bash
./scripts/setup-dns.sh
```

Then apply the DNS configurations:
```bash
KUBECONFIG=configs/cluster1/kubeconfig kubectl apply -f configs/coredns-cluster1.yaml
KUBECONFIG=configs/cluster2/kubeconfig kubectl apply -f configs/coredns-cluster2.yaml

# Restart CoreDNS
KUBECONFIG=configs/cluster1/kubeconfig kubectl rollout restart deployment/coredns -n kube-system
KUBECONFIG=configs/cluster2/kubeconfig kubectl rollout restart deployment/coredns -n kube-system
```

### 5. Test Connectivity

```bash
./scripts/test-connectivity.sh
```

## Available Commands

```bash
make help                 # Show available commands
make setup-network        # Create Podman network only
make create-configs       # Generate Talos configs only
make cluster1-up          # Start only cluster1
make cluster2-up          # Start only cluster2
make clusters-up          # Start both clusters
make cluster1-down        # Stop only cluster1
make cluster2-down        # Stop only cluster2
make clusters-down        # Stop both clusters
make clean                # Clean up everything
make status               # Show cluster status
make kubeconfig-cluster1  # Get kubeconfig for cluster1
make kubeconfig-cluster2  # Get kubeconfig for cluster2
make kubeconfigs          # Get both kubeconfigs
```

## Network Configuration

The clusters are configured with:
- Static IP addressing on the shared network
- Routes between pod networks for direct pod-to-pod communication
- Separate DNS domains to avoid conflicts

## Cross-Cluster Communication

Three levels of connectivity are supported:

1. **IP-level**: Direct pod-to-pod communication via IP addresses
2. **DNS-level**: Service discovery across clusters using DNS
3. **Service-level**: Access services in remote clusters by FQDN

## Troubleshooting

### Podman Issues on macOS

Podman on macOS runs in a VM, which can cause networking issues. If you encounter problems:

```bash
# Restart podman machine
podman machine stop
podman machine start

# Check network connectivity
podman network ls
podman network inspect talos-net
```

### Cluster Startup Issues

```bash
# Check container status
make status

# View logs
podman logs talos-cluster1-master-1
podman logs talos-cluster2-master-1
```

### DNS Issues

```bash
# Check CoreDNS configuration
KUBECONFIG=configs/cluster1/kubeconfig kubectl get cm coredns -n kube-system -o yaml

# Test DNS resolution
KUBECONFIG=configs/cluster1/kubeconfig kubectl run test --image=busybox --rm -it -- nslookup kubernetes.default.svc.cluster2.local
```

## Cleanup

To completely remove all resources:

```bash
make clean
```

This will:
- Stop both clusters
- Remove all containers
- Remove the Podman network
- Clean up configuration files

## Notes

- The configuration assumes single-node clusters (1 master, 1 worker each)
- Pod-to-pod routing is configured at the node level
- DNS forwarding is set up in CoreDNS for cross-cluster service discovery
- All clusters use the same Podman network for simplicity