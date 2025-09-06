---
tags:
- category
- kubernetes
- infrastructure
---

# Kubernetes

:::warning This page is under construction
:::

## Setup

* [Local Kind single-cluster setup](./articles/cluster-local-kind.md)
* [Local Talos multi-cluster setup](./articles/cluster-local-talos.md)

## Addons

## Maintenance

* backup/restore
* upgrade
* autoscaling: karpenter

## Monitoring

## Access Management

* Users: aws-auth, Azure Active Directory
* Services: IRSA, Azure Workload Identity

## Tools

* `ArgoCD`
* `eraser-dev/eraser`   A daemonset responsible for cleaning up outdated images stored in the cluster nodes.
* `emberstack/kubernetes-reflector` Replicate a Secret or configMap between namespaces automatically.
* `kubernetes-sigs/descheduler`   Monitors if workloads are evenly distributed through nodes and cleans failed pods that remained as orphans/stuck.
