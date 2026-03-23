---
sidebar_label: 📍 Roadmap
sidebar_position: 20
---

# Roadmap

**Platform development tracked across versioned milestones.**

**[✨ How it works →](how-it-works.md)**

---

## 0.1.0 self-hosted kubernetes cluster

**Infra requirements:**

- [x] localhosted cluster kind
- [x] kubernetes monitoring: node, dp, ds, sts, pv- (kind do not support)
- [x] pritunl vpn setup doc

**Website requirements:**

- [x] landing page (technologies, skills, links)
- [x] DevOps Sandbox description docs
- [x] **basic demo:** bootstrap local on kind
- [x] **basic demo:** bootstrap on killercoda
- [ ] :arrows_counterclockwise: updated CV + ability to download + links
- [ ] :arrows_counterclockwise: Roadmap planner documented

**Platform & App-library requirements:**

- [x] common applicationset
- [x] basic helm appchart (cloud-dc-env)

**Tools requirements:**

1. deployed
2. basic usage
3. monitoring: (basic dashboard)

**Progress tools:**

- [x] **logging:** elasticsearch, kibana, fluent-bit
- [x] **metrics:** prometheus, grafana, alertmanager
- [x] **postgresql:** cloudnative-pg
- [x] **kafka:** strimzi
- [x] **mongodb:** community-operator
- [x] **certificates:** cert-manager
- [x] **secret storage:** vault + external-secrets
- [x] **ingress:** nginx
- [x] **clickhouse:** altinity
- [x] **redis-operator**

## 0.2.0 self-hosted multi-cluster setup

**Infra requirements:**

- [ ] :arrows_counterclockwise: local multicluster setup
  (special case) monitoring:
    need to have prometheus release in both clusters
    BUT releases have to have differrent names (so services names wont overlap)
    need to adjust argo application to be able to add istio label to namespace
    also i will adjust _chart to create additional service (to match it from another cluster)
  (usual case) elastic logs:
    just use _chart to create service in stage cluster
    and use this service to send logs to it
- [ ] review website design

**Platform & App-library requirements:**

- [x] argocd -- add cluster, appsets
- [ ] applibrary -- crosscluster access via virtualservice
- [ ] :arrows_counterclockwise: argo application tags/labels based on values.yaml integrations (like psql, mongo, migration, etc)
- [ ] :arrows_counterclockwise: argocd -- demo-infra smooth bootstrap (configure autosync in `argo.yaml`)
- [ ] investigate argo teams and projects
- [ ] argocd webhook drifts (external-secrets, vault, https://github.com/argoproj/argo-cd/issues/4326)
  allow to setup ingnoreDiffs from `argo.yaml`

**Tools requirements:**

4. common usage
5. architecture
6. monitoring: how to monitor
7. maintenance: backup/restore

**Progress tools:**

- [ ] crossplane
- [ ] cert-manager: vault-pki or letsencrypt
- [ ] observability: configure prom & alertmanager to common grafana
- [ ] ingress: nginx external-dns
- [ ] logs: configure fluent-bit to common elastic
- [ ] secrets: configure external-secrets to common vault
- [ ] service mesh: istio
- [ ] tracing: tempo/jaeger
- [ ] autoscaling: keda
- [ ] tools: reloader
- [ ] demo-app

## 0.3.0 common eks cluster

**Infra requirements:**

- [ ] aws eks: terrafrom, addons
- [ ] setup pritunl vpn with terragrunt
- [ ] basic IDP webui app

**Platform & App-library requirements:**

- [ ] argocd -- helm post-render + kustomization (ability to make changes in rendered charts)

**Tools requirements:**

8. saas
9. maintenance: scaling/upgrade
10. monitoring: alerts

## 0.4.0 staging eks cluster

**Infra requirements:**

- [ ] cluster-autoscaling: karpenter
- [ ] crossplane: eks provisioning

**Tools requirements:**

11. advanced usage

## 1.0.0 platform app-library

**Infra requirements:**

**Tools requirements:**

12. platform integration

