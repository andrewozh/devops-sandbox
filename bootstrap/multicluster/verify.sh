#!/usr/bin/env bash
set -x

export CTX_CLUSTER1=kind-cluster1
export CTX_CLUSTER2=kind-cluster2

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
