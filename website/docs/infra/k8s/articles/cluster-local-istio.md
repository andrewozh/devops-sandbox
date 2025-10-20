---
tags:
- article
- kubernetes
- infrastructure
---

# Local multi-cluster setup (Kind + MetalLB + Istio + Nginx proxy + DNSMasq)

:::warning This page is under construction
:::

## [+] Kind

- [x] run two basic clusters

## [+] ArgoCD

- [x] auto rename default cluster
- [x] add stage cluster

## [~] Local networking: Ingress + Nginx proxy + DNSMasq

**Ingress:**

- [x] fix main cert autocreation


**Nginx-proxy:**

- [+] docker-compose

**dnsmasq:**

- [ ] setup

## MetalLB

- [x] basic setup -- assign to lb ip address from docker vm pool

## Istio

can i add cluster w/o istio -- yes
setup as helm chart -- not now

## Patch AppChart Platform setup

- globally configurable domain
- how to configure easy hostname adding into configuration?
- how to expose common applications to other clusters?


lets say we have prometheus in common and in stage

1. i have to add special label tp all metrics to diff em by clutter

so i have to create a ??Gateway?? in common cluster
also i have to create a Service in stage cluster
!!! no load balancing, DIRECT ACCESS !!! -- so service do not have to be same


