---
tags:
- article
- kubernetes
- infrastructure
---

# Local multi-cluster setup (Kind + MetalLB + Istio + Nginx proxy + DNSMasq)

:::warning This page is under construction
:::

1. patch /etc/hosts, add ip route, install CA cert
2. 

## Kind

- [x] run two basic clusters

## ArgoCD

- [x] auto rename default cluster
- [x] add stage cluster

## Local networking: Ingress + Nginx proxy + DNSMasq

- configurable after argocd setup

## MetalLB

- [x] basic setup -- assign to lb ip address from docker vm pool

## Istio

- configurable after argocd setup
- [ ] can i add cluster w/o istio -- yes
- [ ] setup as helm chart


