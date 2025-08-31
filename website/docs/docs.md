---
sidebar_label: 🗂️ Docs
sidebar_position: 99
---

# Documentation

## Glossary

The key components of documentation structure:

* `category` -- global large-scale direction topics,  etc (can be nested)
* `tool` -- technologies in categories
* `distro` -- 
* `article`

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

Documentation sidebar structure:

* Articles not listed in sidebar

```
<#category>/
└── <#category>/
    └── <#tool>/
        └── <#distro>
```

Documentation file in repository structure:



---

## Maintenance

### Local development

```bash
cd website
yarn start
```

### Deploy to GitHub Pages

```bash
yarn build
DEPLOYMENT_BRANCH=main GIT_USER=andrewozh yarn deploy
```
