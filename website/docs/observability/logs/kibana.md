# Kibana

|**Distro**|Kibana|
|-|-|
|**Type**|Custom Resource|
|**Deploy**|[ECK OPerator](./elastic-operator.md)|
|**Docs**|[link](https://www.elastic.co/docs/explore-analyze/query-filter/languages/esql)|
|**Backup**||
|**Scaling**||
|**CLI**||
|**UI**||

## Setup

- deployment explained
- how to setup

## Usecases

### :white_check_mark: Basic: Discover all logs

- access kibana with admin `elastic` user

```bash
kubectl get secret elasticsearch-es-elastic-user -n logging -o jsonpath='{.data.elastic}' | base64 -d
```

- view logs

```
`Discover` -> `Data view` -> `Create data view`: {
  `Index pattern` is `logstash-*`,
  `Time field` is `@timestamp`
}
```

## :white_check_mark: Monitoring

:::tip
Kibana can show its metrics: `Management` -> `Stack Monitoring` -> `Kibana`
https://www.elastic.co/docs/deploy-manage/monitor/monitoring-data/kibana-page
:::

## Maintenence

- Backup / Restore
- Scaling
- Upgrade

---

## Articles

* [Example article link](#)


