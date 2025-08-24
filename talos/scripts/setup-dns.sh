#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../configs"

echo "Setting up cross-cluster DNS resolution..."

# Create CoreDNS ConfigMap for cluster1
cat > "$CONFIG_DIR/coredns-cluster1.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster1.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
        }
        forward cluster2.local 172.20.0.20:53
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
EOF

# Create CoreDNS ConfigMap for cluster2
cat > "$CONFIG_DIR/coredns-cluster2.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster2.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
        }
        forward cluster1.local 172.20.0.10:53
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
EOF

echo "DNS configuration files created:"
echo "  - $CONFIG_DIR/coredns-cluster1.yaml"
echo "  - $CONFIG_DIR/coredns-cluster2.yaml"
echo ""
echo "To apply the DNS configuration:"
echo "  KUBECONFIG=configs/cluster1/kubeconfig kubectl apply -f configs/coredns-cluster1.yaml"
echo "  KUBECONFIG=configs/cluster2/kubeconfig kubectl apply -f configs/coredns-cluster2.yaml"
echo ""
echo "Then restart CoreDNS deployments:"
echo "  KUBECONFIG=configs/cluster1/kubeconfig kubectl rollout restart deployment/coredns -n kube-system"
echo "  KUBECONFIG=configs/cluster2/kubeconfig kubectl rollout restart deployment/coredns -n kube-system"