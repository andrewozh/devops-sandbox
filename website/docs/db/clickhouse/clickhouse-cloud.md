# Clickhouse Cloud

|**Tool**|[ClickHouse Cloud](https://clickhouse.com/cloud)|
|-|-|
|**Type**|terrafrom-provider|
|**Deploy**|crossplane|
|**Backup**|manual|
|**Scaling**|automated|
|**CLI**|clickhouse-client|
|**UI**|web|

## TODO

- [ ] add all available settings to XRD
- [ ] automate creation of DB and Users (operator)

## Architectire

Crossplane-terraform + terraform provider for ClickHouse Cloud.
Terrafrom Workspace wrapped in Composition Resource Definition (XRD).
Admin credentials output as a secret.

## Usecases

- Basic: create db, create user, connect, etc.
- Common: write data, read data, replication, etc.

## Maintenence

### Setup

- setup terraform provider

```bash
cat <<EOF > .secret
clickhouse_org: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
clickhouse_key: "xxxxxxxxxxxxxxxxxxxx"
clickhouse_secret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
EOF
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: clickhouse-cloud-secret
  namespace: crossplane
type: Opaque
data:
  creds.auto.tfvars: $(cat .secret | base64)
EOF
```

- create Clickhouse Cloud service

```yaml
apiVersion: clickhousecloud.crossplane.io/v1alpha1
kind: xService
metadata:
  name: clickhouse
spec:
  name: clickhouse
```

### Backup / Restore
### Scaling
### Upgrade

## Patform integration

- how this tool integrated into a platform
- how to use it in a platform
- how to debug

## KNOWN ISSUES

- On `Free Tier` with provider versios 3.3.3 can't update already created service

```
Error: Error setting service backup configuration

with module.dev.module.clickhouse.clickhouse_service.service,
on dev/clickhouse/main.tf line 1, in resource "clickhouse_service" "service":
  1: resource "clickhouse_service" "service" {

Could not update service backup settings, unexpected error: status: 400,
body:
{"requestId":"90ab9fdd-4446-4d44-a9fe-aeecc29af7de","error":"BAD_REQUEST:
cannot update backup configuration for development tier
service","status":400}
```

Related GitHub issue: https://github.com/ClickHouse/terraform-provider-clickhouse/issues/167
