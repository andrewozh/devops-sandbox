#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../configs"

echo "Testing cross-cluster connectivity..."

# Create test pods in both clusters
cat > "$CONFIG_DIR/test-pod-cluster1.yaml" << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: default
  labels:
    app: test-pod
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: default
spec:
  selector:
    app: test-pod
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

cat > "$CONFIG_DIR/test-pod-cluster2.yaml" << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: default
  labels:
    app: test-pod
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: default
spec:
  selector:
    app: test-pod
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

echo "Deploying test pods..."
kubectl --kubeconfig="$CONFIG_DIR/cluster1/kubeconfig" apply -f "$CONFIG_DIR/test-pod-cluster1.yaml"
kubectl --kubeconfig="$CONFIG_DIR/cluster2/kubeconfig" apply -f "$CONFIG_DIR/test-pod-cluster2.yaml"

echo "Waiting for pods to be ready..."
kubectl --kubeconfig="$CONFIG_DIR/cluster1/kubeconfig" wait --for=condition=Ready pod/test-pod --timeout=120s
kubectl --kubeconfig="$CONFIG_DIR/cluster2/kubeconfig" wait --for=condition=Ready pod/test-pod --timeout=120s

echo ""
echo "=== Testing Network Connectivity ==="

echo "1. Testing pod-to-pod IP connectivity..."
CLUSTER2_POD_IP=$(kubectl --kubeconfig="$CONFIG_DIR/cluster2/kubeconfig" get pod test-pod -o jsonpath='{.status.podIP}')
echo "Cluster2 pod IP: $CLUSTER2_POD_IP"

echo "Testing ping from cluster1 pod to cluster2 pod..."
kubectl --kubeconfig="$CONFIG_DIR/cluster1/kubeconfig" exec test-pod -- ping -c 3 "$CLUSTER2_POD_IP" || echo "IP connectivity test failed"

echo ""
echo "2. Testing DNS resolution..."
echo "Testing DNS lookup from cluster1 to cluster2..."
kubectl --kubeconfig="$CONFIG_DIR/cluster1/kubeconfig" exec test-pod -- nslookup test-service.default.svc.cluster2.local || echo "DNS resolution test failed"

echo ""
echo "3. Testing service connectivity..."
echo "Testing service connectivity from cluster1 to cluster2..."
kubectl --kubeconfig="$CONFIG_DIR/cluster1/kubeconfig" exec test-pod -- wget -qO- --timeout=5 test-service.default.svc.cluster2.local:8080 || echo "Service connectivity test failed"

echo ""
echo "Cleanup test resources..."
kubectl --kubeconfig="$CONFIG_DIR/cluster1/kubeconfig" delete -f "$CONFIG_DIR/test-pod-cluster1.yaml" --ignore-not-found
kubectl --kubeconfig="$CONFIG_DIR/cluster2/kubeconfig" delete -f "$CONFIG_DIR/test-pod-cluster2.yaml" --ignore-not-found

echo "Connectivity test complete!"