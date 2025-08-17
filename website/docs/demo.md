---
sidebar_position: 80
---

# Demo

## KILLERCODA

https://killercoda.com/playgrounds/scenario/kubernetes
- 2x2Gb
- 1x4Gb

- [+] find a demo environment (local macos, linux)
- [ ] argocd watch local repository (to be able to commit new application)
- [ ] lightweight `demo` branch of this project
- [ ] single command to bootstrap demo cluster


## SCENARIO

- user runs remote `bootstrap.sh`
- fetch current repo
- local DNS and CA configured
- local kubernetes is up
- script installs argocd
- argocd sync all other apps
- user easily deploy new app

---

## Local Kind

1. Setup local DNS and add CA

2. Start local Kubernetes cluster
  - apply required secrets

2. Deploy ArgoCD
  - apply first application

3. Autosync Essential Apps
  - cert-manager
  - ingress-nginx
  - prometheus-stack

4. Required apps
  - vault
  - external-secrets
  - elk

5. Optional apps
  - postgres
  - kafka
  - mongo
  - redis
  - clickhouse

### demo apps: producer/consumer

- have web-ui
- shows secrets
- db connection status
- shows data from databases
- add message in producer-app
- appear message in consumer app
- have metrics
