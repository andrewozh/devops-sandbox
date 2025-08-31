# Kubernetes

* [Local Kind single-cluster setup](./cluster-local-kind.md)
* [Local Talos multi-cluster setup](./cluster-local-talos.md)

## Tools

* `Terraform/Terragrunt`
* `Crossplane`

## TODO

- picture of cluster arch
- kubernetes bootstrap: local / managed, addons
- how to cluster upgrade

## management

* setup and configuration: no clickops (ability to redeploy from scratch),
* usability: gitops by infra-platform tools (values.yaml)
* monitoring
* maintenance: backup/restore, upgrade, scaling

## IRSA

## Cluster autoscaling

* AWS Karpenter

## Tools

* `crossplane`
* `keda`
* `reloader`
* `eraser-dev/eraser`   A daemonset responsible for cleaning up outdated images stored in the cluster nodes.
* `emberstack/kubernetes-reflector` Replicate a Secret or configMap between namespaces automatically.
* `kubernetes-sigs/descheduler`   Monitors if workloads are evenly distributed through nodes and cleans failed pods that remained as orphans/stuck.
