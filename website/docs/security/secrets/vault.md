# Vault

|**Distro**|[Hashicorp Vault](https://developer.hashicorp.com/vault)|
|-|-|
|**Type**|kubernetes stateful app|
|**Deploy**|[helm-chart](https://developer.hashicorp.com/vault/docs/deploy/kubernetes/helm)|
|**Docs**|[link](https://developer.hashicorp.com/vault/docs)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**|web|

## Setup

:::note
Default configuration
:::

## :white_check_mark: Usecases

[Why use Vault](https://developer.hashicorp.com/vault/tutorials/get-started/why-use-vault)

### :white_check_mark: Basic: Manually unseal vault

- init vault & temporary save unseal keys and root token

```bash
kubectl exec -n vault -t vault-0 -- vault operator init > .secret
```

- manually unseal vault

```bash
while read -r line ; do
  KEY=$(echo "$line" | grep Unseal | awk '{print $4}')
  [ ! -z "$KEY" ] && kubectl exec -n vault -t vault-0 -- vault operator unseal $KEY
done < .secret
```

- add secret with vault token

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
  namespace: vault
type: Opaque
stringData:
  token: $(cat .secret | grep "Initial Root Token" | awk -F': ' '{print $2}')
EOF
```

### Common: Vault injector

- [ ] TLS
- [ ] HA mode

### Advanced

- [ ] configurable backend (local, aws ssm, etc)
- [ ] auto unseal

## :white_check_mark: Monitoring

:::note Grafana Dashboard
https://grafana.com/grafana/dashboards/12904-hashicorp-vault/
:::

:::warning Enterprise-level metrics
vault_secret_kv_count
vault_identity_num_entities
vault_identity_entity_alias_count
vault_token_count
vault_token_count_by_policy
vault_token_count_by_ttl
vault_token_count_by_auth
vault_token_create_count
vault_token_store_count
vault_token_lookup_count
vault_token_creation
vault_audit_log_request_count
vault_audit_log_request_failure
vault_audit_log_response_count
vault_audit_log_response_failure
vault_policy_set_policy_count
vault_policy_get_policy_count
vault_route_create_*
vault_route_delete_*
vault_route_read_*
vault_route_list_*
vault_route_rollback_*
:::

- configure `monitoring`

  * Vault exposes metrics at /v1/sys/metrics?format=prometheus (on port 8200).
  * Metrics are accessible without authentication.
  * The Prometheus Operator (via ServiceMonitor) automatically scrapes these metrics.
  * Default alerting rules are set up for Vault metrics in Prometheus.

```yaml
vault:
  global:
    serverTelemetry:
      prometheusOperator: true
  server:
    standalone:
      config: |
        ui = true
        listener "tcp" {
          tls_disable = 1
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          # Enable unauthenticated metrics access (necessary for Prometheus Operator)
          telemetry {
            unauthenticated_metrics_access = "true"
          }
        }
        storage "file" {
          path = "/vault/data"
        }

        # Example configuration for using auto-unseal, using Google Cloud KMS. The
        # GKMS keys must already exist, and the cluster must have a service account
        # that is authorized to access GCP KMS.
        #seal "gcpckms" {
        #   project     = "vault-helm-dev"
        #   region      = "global"
        #   key_ring    = "vault-helm-unseal-kr"
        #   crypto_key  = "vault-helm-unseal-key"
        #}

        # Example configuration for enabling Prometheus metrics in your config.
        telemetry {
          prometheus_retention_time = "30s"
          disable_hostname = true
        }
  serverTelemetry:
    serviceMonitor:
      enabled: true
```

- alerts

```yaml
vault:
  serverTelemetry:
    prometheusRules:
      enabled: true
      rules:
        - alert: vault-HighResponseTime
          annotations:
            message: The response time of Vault is over 500ms on average over the last 5 minutes.
          expr: vault_core_handle_request{quantile="0.5", namespace="vault"} > 500
          for: 5m
          labels:
            severity: warning
        - alert: vault-HighResponseTime
          annotations:
            message: The response time of Vault is over 1s on average over the last 5 minutes.
          expr: vault_core_handle_request{quantile="0.5", namespace="vault"} > 1000
          for: 5m
          labels:
            severity: critical
```


## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles
