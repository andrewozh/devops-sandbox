{{- define "argo.clusterName" -}}
{{- $cloud := index . 1 }}
{{- $account := index . 2 }}
{{- $environment := index . 3 }}
{{- with (index . 0) }}
{{- $clouds := .Values.clouds -}}
{{- $totalClouds := len $clouds -}}
{{- $totalAccounts := 0 -}}
{{- range $cl := $clouds -}}
  {{- $totalAccounts = add $totalAccounts (len $cl.accounts) -}}
{{- end -}}
{{- if and (eq $totalClouds 1) (eq $totalAccounts 1) -}}
  {{- $environment -}}
{{- else -}}
  {{- $cloud -}}-{{- $account -}}-{{- $environment -}}
{{- end -}}
{{- end -}}
{{- end -}}
