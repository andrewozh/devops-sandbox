---
tags:
- article
- eck
- elasticsearch
- logs
- observability
---

# Manage ECK ElasticSearch users as Kubernetes resources

```yaml
es_users:
  - login: andrew-ozhegov
    roles:
      - superuser
      - admin
  - login: jane-doe
    roles:
      - read_only
```

## Architecture (external-secrets)

### Generate user credentials

Use `PushSecret` with generator `Password` to generate creds and store it in `SecretStore`

```yaml
---
apiVersion: generators.external-secrets.io/v1alpha1
kind: Password
metadata:
  name: elasticsearch-password
spec:
  length: 32
  digits: 5
  symbols: 5
  symbolCharacters: "-_$@"
  noUpper: false
  allowRepeat: true
{{- range .Values.es_users }}
---
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: es-user-{{ .login }}
spec:
  refreshInterval: 6h
  secretStoreRefs:
    - name: vault
      kind: ClusterSecretStore
  selector:
    generatorRef:
      apiVersion: generators.external-secrets.io/v1alpha1
      kind: Password
      name: elasticsearch-password
  data:
    - match:
        secretKey: password
        remoteRef:
          remoteKey: elasticsearch_users/{{ .login }}
          property: password
    - match:
        secretKey: username
        remoteRef:
          remoteKey: elasticsearch_users/{{ .login }}
          property: username
    - match:
        secretKey: roles
        remoteRef:
          remoteKey: elasticsearch_users/{{ .login }}
          property: roles
  template:
    data:
      password: "{{ `{{ .password }}` }}"
      username: "{{ .login }}"
      roles: {{ .roles | toJson | quote }}
{{- end }}
```

### Generate fileRealm secret

Use `ExternalSecret` to find all elasticsearch users in `SecretStore` and generate a secret with `fileRealm`

```yaml
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: elasticsearch-filerealm
spec:
  secretStoreRef:
    name: vault
    kind: ClusterSecretStore
  target:
    name: elasticsearch-filerealm
    template:
      engineVersion: v2
      data:
        users: |
          {{ "{{" }}- range $key, $value := . -{{ "}}" }}
          {{ "{{" }}- $decodedValue := ( $value | fromJson ) -{{ "}}" }}
          {{ "{{" }}- $username := get $decodedValue "username" -{{ "}}" }}
          {{ "{{" }}- $password := get $decodedValue "password" -{{ "}}" }}
          {{ "{{" }} (printf "%s" (htpasswd $username $password)) {{ "}}" }}{{ "{{" }} "\n" {{ "}}" }}
          {{ "{{" }}- end -{{ "}}" }}
        users_roles: |
          {{ "{{" }}- range $key, $value := . -{{ "}}" }}
          {{ "{{" }}- $decodedValue := ( $value | fromJson ) -{{ "}}" }}
          {{ "{{" }}- $roles    := get $decodedValue "roles" | fromJson -{{ "}}" }}
          {{ "{{" }}- $username := get $decodedValue "username" -{{ "}}" }}
          {{ "{{" }}- range $role := $roles -{{ "}}" }}
          {{ "{{" }} $role {{ "}}" }}:{{ "{{" }} $username {{ "}}" }}{{ "{{" }} "\n" {{ "}}" }}
          {{ "{{" }}- end -{{ "}}" }}
          {{ "{{" }}- end -{{ "}}" }}
  dataFrom:
  - find:
      conversionStrategy: Default
      decodingStrategy: None
      path: elasticsearch_users
```

### Configure ECK to use fileRealm

```yaml
eck-stack:
  eck-elasticsearch:
    auth:
      fileRealm:
        - secretName: fluentbit-user-secret
        - secretName: elasticsearch-filerealm
      roles:
        - secretName: elasticsearch-roles
```
