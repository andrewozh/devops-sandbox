#!/usr/bin/env bash
set -x

export CTX_CLUSTER1=kind-common
export CTX_CLUSTER2=kind-stage

# https://istio.io/latest/docs/setup/install/multicluster/primary-remote/
kind create cluster --name common

# helm repo add metallb https://metallb.github.io/metallb
kubectl create ns metallb-system
helm install metallb metallb/metallb --namespace metallb-system
sleep 10
kubectl apply -f metallb-config.yaml

istioctl install --context="${CTX_CLUSTER1}" -f istio-common.yaml

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/multicluster/gen-eastwest-gateway.sh -O
# chmod +x gen-eastwest-gateway.sh
./gen-eastwest-gateway.sh --network common | istioctl --context="${CTX_CLUSTER1}" install -y -f -

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/multicluster/expose-istiod.yaml -O
kubectl apply --context="${CTX_CLUSTER1}" -n istio-system -f expose-istiod.yaml

kubectl --context="${CTX_CLUSTER1}" apply -n istio-system -f \
  ./expose-services.yaml

# -------

kind create cluster --name stage

kubectl create ns --context="${CTX_CLUSTER2}" metallb-system
helm install metallb metallb/metallb --namespace metallb-system
for t in {1..10}; do
  kubectl apply --context="${CTX_CLUSTER2}" -f metallb-config.yaml && break || sleep $t
done

kubectl --context="${CTX_CLUSTER2}" create namespace istio-system
kubectl --context="${CTX_CLUSTER2}" annotate namespace istio-system topology.istio.io/controlPlaneClusters=common
kubectl label --context="${CTX_CLUSTER2}" namespace istio-system topology.istio.io/network=stage

export DISCOVERY_ADDRESS=$(kubectl \
  --context="${CTX_CLUSTER1}" \
  -n istio-system get svc istio-eastwestgateway \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
yq '.spec.values.global.remotePilotAddress = "'${DISCOVERY_ADDRESS}'"' istio-stage.yaml
istioctl install --context="${CTX_CLUSTER2}" -f istio-stage.yaml

export HOSTIP_CLUSTER2=$(kubectl get po \
  --context="${CTX_CLUSTER2}" \
  -n kube-system -o wide \
  kube-apiserver-stage-control-plane \
  -o jsonpath='{.status.hostIP}')
istioctl create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --server="https://${HOSTIP_CLUSTER2}:6443" \
  --name=stage >istio-stage-secret.yaml
kubectl apply -f istio-stage-secret.yaml --context="${CTX_CLUSTER1}"

./gen-eastwest-gateway.sh \
  --network stage |
  istioctl --context="${CTX_CLUSTER2}" install -y -f -

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
