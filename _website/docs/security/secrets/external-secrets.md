# external-secrets

|**Distro**|[external-secrets](https://external-secrets.io)|
|-|-|
|**Type**|kubernetes-operator|
|**Deploy**|helm-chart|
|**Docs**|[link](https://external-secrets.io/latest/)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**||

## Architecture

[Source](https://external-secrets.io/v0.8.1/guides/multi-tenancy/)

**Shared ClusterSecretStore:** 
![Shared ClusterSecretStore diagram](.img/external-secrets-shared-cluster-secret-store.png)

## :white_check_mark: Setup

### :white_check_mark: Hashicorp Vault

See [Vault](vault.md) docs for more details.

- Create a Vault engine path:
  `Secret Engines` -> `Enable new engine +` -> `KV` -> Path: `common`

- Createa `ClusterSecretStore` for Vault

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault
spec:
  provider:
    vault:
      server: "http://vault.vault.svc.cluster.local:8200"
      path: "common"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          namespace: vault
          key: "token"
```

## Usecases

### :white_check_mark: Basic: get secret, add secret from secret store

- example `ExternalSecret` to read secret from secret store

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: test
  namespace: default
spec:
  refreshInterval: 10m
  secretStoreRef:
    name: vault
    kind: ClusterSecretStore
  target:
    name: test
    creationPolicy: Owner
  dataFrom:
  - extract:
      key: "/test"
```

- example `PushSecret` from k8s to secret store

Usecase: some resource created in k8s store its secret in k8s-secret,
and we use PushSecret to save it in Vault and be accessible outside of k8s

[Source](https://external-secrets.io/latest/guides/pushsecrets/)

```yaml
cat <<EOF | kubectl apply -f -
---
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: argocd-secret # Customisable
  namespace: argocd # Same of the SecretStores
spec:
  updatePolicy: Replace # Policy to overwrite existing secrets in the provider on sync
  deletionPolicy: Delete # the provider' secret will be deleted if the PushSecret is deleted
  refreshInterval: 10m # Refresh interval for which push secret will reconcile
  secretStoreRefs: # A list of secret stores to push secrets to
    - name: vault
      kind: ClusterSecretStore
  selector:
    secret:
      name: argocd-secret # Source Kubernetes secret to be pushed
  data:
    - conversionStrategy: None # Also supports the ReverseUnicode strategy
      match:
        # secretKey: best-pokemon # Source Kubernetes secret key to be pushed (comment out to push all keys)
        remoteRef:
          remoteKey: argocd/admin # Remote reference (where the secret is going to be pushed)
EOF
```

### Common: generate secrets, update secrets, rotate secrets

## :white_check_mark: Monitoring

[Docs](https://external-secrets.io/v0.19.0/api/metrics/)

:::note Grafana Dashboard
https://raw.githubusercontent.com/external-secrets/external-secrets/main/docs/snippets/dashboard.json
:::
```yaml

external-secrets:
  serviceMonitor:
    enabled: true
```

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles
