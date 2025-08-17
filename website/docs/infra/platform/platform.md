# GitOps Platform

## KCL

* main `argocd` application
  creates `ApplicationSet`
  do i need specific KCL functions for this?

* `ApplicationSet` generates `Applications`
  `<app>/releases/<release>/argo.yaml`
  argo application settings
  deploy/exclude
  etc..

  can KCL fetch helm chart and set the values? (helm operator, HelmRelease resourse as part of kcl app)
  how kcl will know values for different env?

## ArgoCD

- argocd appset schema
- how to setup argocd

- [?] Split applications (charts) and releases
  we have a single directory for apps (charts)
  and we have a separate directory for releases
  each release refers to a chart
  also each release keep current values folder structure for sophisticated overrides

## App-library

* [App-library Helm chart](./applibrary-helm-chart.md)

