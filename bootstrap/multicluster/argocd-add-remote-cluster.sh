# login
argocd login argocd.home.lab:8443 --username admin --password admin --insecure

# rename in-cluster to common
cat <<EOF
apiVersion: v1
kind: Secret
metadata:
    name: common-cluster
    namespace: argocd
    labels:
        argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
    name: common
    server: https://kubernetes.default.svc
    config: |-
        {
          "tlsClientConfig":{
            "insecure":false
          }
        }
EOF

# add stage

# Switch to stage cluster and create service account
kubectl config use-context kind-stage

# Create service account for ArgoCD
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: kube-system
EOF

# Create a long-lived token for the service account
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: argocd-manager-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: argocd-manager
type: kubernetes.io/service-account-token
EOF

# Get the token
TOKEN=$(kubectl get secret argocd-manager-token -n kube-system -o jsonpath='{.data.token}' | base64 -d)

# Get the CA certificate
CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# Get the stage cluster container IP
STAGE_IP=$(docker inspect stage-control-plane -f '{{.NetworkSettings.Networks.kind.IPAddress}}')

# Switch to common cluster
kubectl config use-context kind-common

# Create the cluster secret in ArgoCD
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: stage-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: stage
  server: https://${STAGE_IP}:6443
  config: |
    {
      "bearerToken": "${TOKEN}",
      "tlsClientConfig": {
        "caData": "${CA_CERT}",
        "insecure": false
      }
    }
EOF

echo "Stage cluster added successfully!"
echo "Server URL: https://${STAGE_IP}:6443"
