---
sidebar_label: ✨ Intro
sidebar_position: 1
---

# DevOps Sandbox

All in one project with useful **devops practices** and tools as **demo** of my skills, **sandbox** for learning new tools and **infra foundation** for companies of any size.

![devops-sandbox](.img/devops-sandbox.excalidraw.png)

**Lead technologies:**

* **terraform:** provision clouds, vpn, common kubernetes clusters
* **crossplane:** provision additional environments
* **argocd**: provision applications gitops way
* **appchart:** DRY app configuration on different environments

## How to read docs

**This documentation is organized hierarchically using four key components:**

- **Categories** - Large-scale topics like Infrastructure, Networking, Observability
- **Tools** - Core technologies like Kubernetes, Prometheus, ElasticSearch
- **Distros** - Specific implementations like ECK, Strimzi, Talos
- **Articles** - Implementation guides and tutorials (accessible by links on pages)

```
<#category>/
└── <#category>/
    └── <#tool>/
        └── <#distro>
```

Each documentation page have appropriate tag!

📖 **[Full documentation structure and guidelines →](docs.md)**

## Further reading

- **[Infrastructure](infra/infra.md)** -- detailed documentation of the whole infra-platform
- **[Roadmap](roadmap.md)** -- what's done, what's next, what's planned
- **[Demo](/demo)** -- run devops-sandbox yourself
