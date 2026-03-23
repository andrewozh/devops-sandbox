---
sidebar_label: 🗂️ Docs
sidebar_position: 10
---

# Documentation

![docs-structure](.img/docs-structure.png)

## Structure

```
<#category>/
├── <#category>/
│   ├── <#tool>/
│   │   ├── <#distro>/
│   │   │   └── <#article>
│   │   └── <#article>
│   └── <#article>
└── <#article>
```

### Category

Large-scale topic area. Can be nested, can contain tools, distros, and articles directly.
May have no page of its own — just a folder with `_category_.json` as a sidebar label.

### Tool

Core technology within a category. Can contain distros and articles.

### Distro

Specific distribution, operator, or managed implementation of a tool. Can have its own articles.

### Article

Implementation guide or deep-dive scoped to a parent tool, distro, or category.
Always positioned at the bottom of its parent.

## File placement

```
devops-sandbox/website/docs/
├── .img/
└── db/
    ├── _category_.json                           (#category, no page)
    └── clickhouse/
        ├── .img/
        ├── clickhouse.md                         (#category with page, no _category_.json)
        ├── differrence-between-cloud-and-self-hosted.md  (#article)
        ├── clickhouse-cloud.md                   (#distro)
        └── altinity/
            ├── .img/
            ├── altinity.md                       (#distro)
            ├── altinity-setup-low-resource.md    (#article)
            └── altinity-automatic-backup.md      (#article)
```

Images go into a `.img/` subfolder next to the page that uses them:

```markdown
![img-name](.img/img-name.png)
```

### Frontmatter

Prefer frontmatter in the markdown file over `_category_.json` where possible.
Use `sidebar_label` to set the icon + display name, `sidebar_position` to control order.

```yaml
---
sidebar_label: 🟨 ClickHouse
sidebar_position: 1
tags:
- tool
- clickhouse
- database
---
```

### Icons

All sidebar labels must include an emoji. Icons go in `sidebar_label` only — not in the H1 heading.
Use any appropriate emoji for categories, tools, and distros. Articles always use 📄.

### Tags

First tag is the page type, second is the component name, the rest inherit from parent pages:

```yaml
tags:
- distro        # page type
- altinity      # component name
- clickhouse    # parent tool
- database      # parent category
```

## Search

Search by `Ctrl+K` / `Cmd+K`. Tag-based filtering is not supported by `docusaurus-search-local`.

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

### Keep repo clean

Remove large unused files from git history to keep repo size under control:

```bash
brew install bfg
bfg --delete-files pritunl-cloud-architecture.png
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```
