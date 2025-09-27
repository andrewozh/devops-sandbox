#!/usr/bin/env bash
set -x

export CTX_CLUSTER1=kind-cluster1
export CTX_CLUSTER2=kind-cluster2

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/kind-lb/setupkind.sh -O
# chmod +x setupkind.sh
# ./setupkind.sh --cluster-name cluster-1 --ip-space 254
# ./setupkind.sh --cluster-name cluster-2 --ip-space 255

# https://istio.io/latest/docs/setup/install/multicluster/primary-remote/
kind create cluster --config cluster1-config.yaml

# helm repo add metallb https://metallb.github.io/metallb
kubectl create ns metallb-system
helm install metallb metallb/metallb --namespace metallb-system
kubectl apply -f metallb-config.yaml

istioctl install --context="${CTX_CLUSTER1}" -f cluster1.yaml

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/multicluster/gen-eastwest-gateway.sh -O
chmod +x gen-eastwest-gateway.sh
./gen-eastwest-gateway.sh --network network1 | istioctl --context="${CTX_CLUSTER1}" install -y -f -

# curl https://raw.githubusercontent.com/istio/istio/release-1.27/samples/multicluster/expose-istiod.yaml -O
kubectl apply --context="${CTX_CLUSTER1}" -n istio-system -f expose-istiod.yaml

# -------

kind create cluster --name cluster2 --config cluster2-config.yaml

kubectl --context="${CTX_CLUSTER2}" create namespace istio-system
kubectl --context="${CTX_CLUSTER2}" annotate namespace istio-system topology.istio.io/controlPlaneClusters=cluster1

export DISCOVERY_ADDRESS=$(kubectl \
  --context="${CTX_CLUSTER1}" \
  -n istio-system get svc istio-eastwestgateway \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

yq '.spec.values.global.remotePilotAddress = "'${DISCOVERY_ADDRESS}'"' cluster2.yaml

istioctl install --context="${CTX_CLUSTER2}" -f cluster2.yaml

export HOSTIP_CLUSTER2=$(kubectl get po \
  --context="${CTX_CLUSTER2}" \
  -n kube-system -o wide \
  kube-apiserver-cluster2-control-plane \
  -o jsonpath='{.status.hostIP}')
istioctl create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --server="https://${HOSTIP_CLUSTER2}:6443" \
  --name=cluster2 >cluster2-secret.yaml
kubectl apply -f cluster2-secret.yaml --context="${CTX_CLUSTER1}"

kubectl label --context=kind-cluster2 namespace istio-system topology.istio.io/network=network1

kubectl patch mutatingwebhookconfiguration istio-sidecar-injector \
  --context=kind-cluster2 \
  --type='json' \
  -p='[{
      "op": "replace",
      "path": "/webhooks/0/clientConfig/service",
      "value": null
    },{
      "op": "replace",
      "path": "/webhooks/0/clientConfig/url",
      "value": "https://172.18.255.201:15012/inject/cluster/cluster2/net/network1"
    }]'
