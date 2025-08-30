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

## Deployment method priorities

1   SaaS
2   k8s operator (olm, self-managed)
3   helm-chart
3.1 official
3.2 community
4.  self-managed

## management

* setup and configuration: no clickops (ability to redeploy from scratch),
* usability: gitops by infra-platform tools (values.yaml)
* monitoring
* maintenance: backup/restore, upgrade, scaling

## Tools

* crossplane
* keda
* reloader

* `eraser-dev/eraser`   A daemonset responsible for cleaning up outdated images stored in the cluster nodes.


* `emberstack/kubernetes-reflector` Replicate a Secret or configMap between namespaces automatically.

* `kubernetes-sigs/descheduler`   Monitors if workloads are evenly distributed through nodes and cleans failed pods that remained as orphans/stuck.

* sandbox pod

kubectl run dev-sandbox --image=ubuntu --restart=Always --command -- sleep infinity

#
