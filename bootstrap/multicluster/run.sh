#!/usr/bin/env bash
set -x
set -e

# https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/

export CTX_CLUSTER1=kind-common
export CTX_CLUSTER2=kind-stage

function deploy_metallb {
  local ctx=$1
  kubectl --context="${ctx}" get deployment -n metallb-system metallb-controller >/dev/null 2>&1 && return
  helm repo add metallb https://metallb.github.io/metallb
  helm install --kube-context="${1}" metallb metallb/metallb --namespace metallb-system --create-namespace
  kubectl --context="${1}" wait -n metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
  kubectl apply --context="${1}" -f metallb-config.yaml
}

# PRIMARY CLUSTER

kind get clusters | grep common || kind create cluster --config common/kind.yaml

deploy_metallb "${CTX_CLUSTER1}"

istioctl --context="${CTX_CLUSTER1}" install -y -f common/istio.yaml

istioctl --context="${CTX_CLUSTER1}" install -y -f common/istio-eastwest-gateway.yaml

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/multicluster/expose-istiod.yaml -O
kubectl apply --context="${CTX_CLUSTER1}" -n istio-system -f common/expose-istiod.yaml

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/multicluster/expose-services.yaml -O
kubectl apply --context="${CTX_CLUSTER1}" -n istio-system -f common/expose-services.yaml

# REMOTE CLUSTER

kind get clusters | grep stage || kind create cluster --config stage/kind.yaml

deploy_metallb "${CTX_CLUSTER2}"

kubectl --context="${CTX_CLUSTER2}" create namespace istio-system
kubectl --context="${CTX_CLUSTER2}" annotate namespace istio-system topology.istio.io/controlPlaneClusters=common
kubectl label --context="${CTX_CLUSTER2}" namespace istio-system topology.istio.io/network=stage

export DISCOVERY_ADDRESS=$(kubectl \
  --context="${CTX_CLUSTER1}" \
  -n istio-system get svc istio-eastwestgateway \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
yq '.spec.values.global.remotePilotAddress = "'${DISCOVERY_ADDRESS}'"' stage/istio.yaml
istioctl --context="${CTX_CLUSTER2}" install -y -f stage/istio.yaml

export HOSTIP_CLUSTER2=$(kubectl get po \
  --context="${CTX_CLUSTER2}" \
  -n kube-system -o wide \
  kube-apiserver-stage-control-plane \
  -o jsonpath='{.status.hostIP}')
istioctl create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --server="https://${HOSTIP_CLUSTER2}:6443" \
  --name=stage >stage/istio-remote-secret.yaml
kubectl apply -f stage/istio-remote-secret.yaml --context="${CTX_CLUSTER1}"

istioctl --context="${CTX_CLUSTER2}" install -y -f stage/istio-eastwest-gateway.yaml

exit 0

### VERIFY

kubectl create --context="${CTX_CLUSTER1}" namespace sample
kubectl create --context="${CTX_CLUSTER2}" namespace sample

kubectl label --context="${CTX_CLUSTER1}" namespace sample \
  istio-injection=enabled
kubectl label --context="${CTX_CLUSTER2}" namespace sample \
  istio-injection=enabled

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/helloworld/helloworld.yaml -O
kubectl apply --context="${CTX_CLUSTER1}" \
  -f helloworld.yaml \
  -l service=helloworld -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
  -f helloworld.yaml \
  -l service=helloworld -n sample

kubectl apply --context="${CTX_CLUSTER1}" \
  -f helloworld.yaml \
  -l version=v1 -n sample

kubectl apply --context="${CTX_CLUSTER2}" \
  -f helloworld.yaml \
  -l version=v2 -n sample

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/curl/curl.yaml -O
kubectl apply --context="${CTX_CLUSTER1}" \
  -f curl.yaml -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
  -f curl.yaml -n sample
