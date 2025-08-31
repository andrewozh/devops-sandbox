# DevOps Sandbox Demo

## 💻 Local setup on Kind

:::warning Requirements
- **macOS/Linux**
- **podman vm (4 CPU and 8GB RAM)**
- **kind**
- **sudo** - for installing home.lab local certs (do not trust, just check the code)
:::

### 1. bootstrap

```bash
bash <(curl -s https://raw.githubusercontent.com/andrewozh/devops-sandbox/refs/heads/main/bootstrap/kind/bootstrap.sh)
```

### 2. port-forward argocd and see the sync process

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

[ArgoCD (localhost)](http://localhost:8080)

:::note Essential apps (autosync)
  - argocd 
  - ingress-nginx
  - cert-manager
  - prometheus-stack
:::

### 3. Sync other infra apps

:::note Required apps
- vault
- external-secrets
- elk
:::

:::note Optional apps
- postgres
- kafka
- mongo
- redis
- clickhouse
:::

### Access apps UI

* [ArgoCD](https://argocd.home.lab)
* [Grafana](https://grafana.home.lab)
* [Kibana](https://kibana.home.lab)
* [Vault](https://vault.home.lab)

### (TODO) 4. Deploy demo apps: producer/consumer

- have web-ui
- shows secrets
- db connection status
- shows data from databases
- add message in producer-app
- appear message in consumer app
- have metrics

---

## 📺 Remote playground on KillerCoda

:::warning Limited environment
The resources of killercoda playground are limited, so we cant install heavy apps like: ELK, Postgres, Kafka, MongoDB, Redis, Clickhouse.
Autosync enabled only for: argocd and prometheus-stack.
:::

### 1. start environment

:::note Free online kubernetes playground
- https://killercoda.com/playgrounds/scenario/kubernetes
[Single 4Gb Node](https://killercoda.com/playgrounds/course/kubernetes-playgrounds/one-node-4GB)
:::

### 2. bootstrap devops-sandbox

```bash
bash <(curl -s https://raw.githubusercontent.com/andrewozh/devops-sandbox/refs/heads/main/bootstrap/demo/bootstrap.sh)
```

### 3. access ArgoCD UI

```
Upper Right corner -> Traffic / Ports -> 30080
```

### 4. sync other infra apps
