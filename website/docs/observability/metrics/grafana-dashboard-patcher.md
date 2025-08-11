# Grafana Dashboard patcher

## TODO

- fix: only forst metric in `expr` is patched

## Tool

- add specific variables
- patch all metrics in expr to use variables

```bash
INPUT_FILE="$1"
jq '.templating.list += [
    {
      "name": "datacenter",
      "query": "label_values(kube_deployment_labels,datacenter)",
      "label": "Datacenter",
      "type": "query",
      "datasource": null,
      "refresh": 1,
      "includeAll": false,
      "multi": false
    },
    {
      "name": "cluster",
      "query": "label_values(kube_deployment_labels{datacenter=\"$datacenter\"},clusterID)",
      "label": "Cluster",
      "type": "query",
      "datasource": null,
      "refresh": 1,
      "includeAll": false,
      "multi": false
    }
  ] | (.. | objects | select(has("expr")) | .expr) |= sub("\\{"; "{datacenter=\"$datacenter\",clusterID=\"$cluster\",")
' "$INPUT_FILE" >"$INPUT_FILE.tmp" && mv "$INPUT_FILE.tmp" "$INPUT_FILE"
```
