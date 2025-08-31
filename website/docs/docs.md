---
sidebar_label: 🗂️ Docs
sidebar_position: 99
---

# Documentation

## Glossary

The key components of documentation structure:

* `category`   -- global large-scale direction topics,  etc (can be nested)
* `tool`       -- core technologies within categories
* `distro`     -- specific distributions, operators, or managed implementations of tools
* `article`    -- implementation guides, architecture explanations, configuration tutorials, and best practices

Each documentation page must have appropriate tag.

```
Observability (#category)/
└── Logs (#category)/
    └── ElasticSearch (#tool)/
        ├── ElasticSeach Architecture (#article)
        └── Elastic Cloud on Kubernetes (#distro)
            └── Manage ECK ElasticSearch users as Kubernetes resources (#article)
```

## Structure

### Documentation sidebar structure

:::warning Articles should not be listed in sidebar
:::

```
<#category>/
└── <#category>/
    └── <#tool>/
        └── <#distro>
```

### Documentation files in repository

```
docs/
└── db/
    ├── db.md (#category)
    ├── _category_.json (#category)
    └── clickhouse/
        ├── clickhouse.md (#tool)
        ├── articles/
        │   └── differrence-between-cloud-and-self-hosted.md (#article)
        ├── clickhouse-cloud.md (#distro)
        └── altinity/
            ├── altinity.md (#distro)
            └── articles/
                ├── altinity-setup-low-resource.md (#article)
                └── altinity-automatic-backup.md (#article)
```

---

## Maintenance

#### Local development

```bash
cd website
yarn start
```

#### Deploy to GitHub Pages

```bash
yarn build
DEPLOYMENT_BRANCH=main GIT_USER=andrewozh yarn deploy
```
