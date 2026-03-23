---
sidebar_label: 📄 How it works
sidebar_position: 90
tags:
- article
- roadmap
---

# How it works

**Ideas move through four stages before becoming part of the platform:**

**[📥 Inbox](inbox.md) → [🗃️ Planner](planner.md) → [📍 Roadmap](roadmap.md) → [📜 Archive](archive.md)**

| Stage | Purpose |
|-|-|
| **Inbox** | Dump any new idea, no filtering |
| **Planner** | Sort and group ideas into categories |
| **Roadmap** | Commit ideas to a versioned milestone |
| **Archive** | Completed milestones |

## Milestone structure

Each milestone may contain few requirement sections:

| Section | Description |
|-|-|
| **Infra requirements** | Cluster, network, and infrastructure tasks |
| **Website requirements** | website and documentation tasks |
| **Platform & App-library requirements** | ArgoCD, app delivery, and platform tooling tasks |
| **Tools requirements** | Maturity level goals for all tracked tools |

**Tools progress** through numbered maturity levels across milestones — **[→ Tools requirements](tools-requirements.md)**

## Versioning

Milestones follow `major.minor.patch`:

| Segment | Meaning |
|-|-|
| **major** | Platform maturity level (`0.x` = pre-production, `1.0` = production-ready) |
| **minor** | New infrastructure phase or capability set |
| **patch** | Fixes, small improvements, doc updates within a milestone |
