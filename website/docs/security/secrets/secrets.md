# Secrets Management

||Secret Manager|Secret Storage|
|-|-|-|
|**Tool**|[external-secrets](external-secrets.md)|[Hashicorp Vault](vault.md)|
|**Type**|kubernetes-operator|kubernetes stateful application|
|**Deploy**|helm-chart|helm-chart|

## Architecture

Simple setup with self-hosted HashiCorp Vault and External Secrets Operator (ESO) to manage secrets in Kubernetes.

```
  +---------------------+
  |  HashiCorp Vault    |
  |---------------------|
  |  Secrets Backend    |
  |  (e.g., KV v2)      |
  +----------^----------+
             |
  [Vault API - HTTPS]
             |
  +----------v----------+
  | External Secrets    |
  |   Operator (ESO)    |
  |---------------------|
  | - Runs in Kubernetes|
  | - Auths to Vault    |
  | - Syncs secrets     |
  +----------v----------+
             |
  +----------v----------+
  | Kubernetes Secret   |
  |(auto-created by ESO)|
  +----------v----------+
             |
  +----------v----------+
  | Application Pod     |
  | (uses the secret)   |
  +---------------------+
```

## Patform integration

- how this tool integrated into a platform
- how to use it in a platform
- how to debug
