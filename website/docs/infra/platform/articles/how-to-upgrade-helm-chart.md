---
tags:
- article
- platform
- infrastructure
---

# How to upgrade helm chart

```bash
$  cat applications/kube-prometheus-stack/Chart.yaml
apiVersion: v1
name: prom-stack
version: 0.1.0
dependencies:
  - name: kube-prometheus-stack
    version: "65.1.1"
    repository: https://prometheus-community.github.io/helm-charts
  - name: chart
    version: 0.1.0
    repository: file://../../_chart

# check for a new version of a helm chart
$  helm repo add kube-prometheus-stack https://prometheus-community.github.io/helm-charts
"kube-prometheus-stack" already exists with the same configuration, skipping

$  helm search repo kube-prometheus-stack/kube-prometheus-stack
NAME                                            CHART VERSION   APP VERSION     DESCRIPTION
kube-prometheus-stack/kube-prometheus-stack     72.8.0          v0.82.2         kube-prometheus-stack collects Kubernetes manif...

# update chart version
$ yq eval ' (.dependencies[] | select(.name == "kube-prometheus-stack") .version) = "72.8.0" ' -i  applications/kube-prometheus-stack/Chart.yaml

# update chart values.yaml
$ helm show values kube-prometheus-stack/kube-prometheus-stack --version 72.8.0 > applications/kube-prometheus-stack/values.yaml

# commit changes
$ git add apps-common/kube-prometheus-stack/*
$ git commit -m "upgrade kube-prometheus-stack chart to 72.8.0"
```
