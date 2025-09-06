---
tags:
- article
- platform
- infrastructure
---

# Configuration Files Hierarchy

## Overview

This document describes a binary-based configuration file ordering system inspired by Linux file permissions. The system provides a predictable and logical way to manage configuration overrides from the most general to the most specific settings.

## Core Concept

:::warning naming
In this example, to make it simple i'll use direct names `cloud`, `account`, and `environment` as configuration scopes. In real scenarios, you'll use the actual names like `aws`, `enterprise`, `production`, etc.
:::

`{cloud}-{account}-{environment}.values.yaml`

The system uses a 3-bit binary representation where each bit position represents a configuration scope:

- **Bit 2**: Cloud
- **Bit 1**: Account
- **Bit 0**: Environment

Each bit can be:
- `0` - Component not specified
- `1` - Component specified

## Binary to Configuration Mapping

The binary value directly translates to the configuration file name and its override priority:

| Binary | Decimal | Configuration File | Description |
|--------|---------|-------------------|-------------|
| `000` | 0 | `values.yaml` | Base configuration (most general) |
| `001` | 1 | `environment.values.yaml` | Environment-specific |
| `010` | 2 | `account.values.yaml` | Account-specific |
| `011` | 3 | `account-environment.values.yaml` | Account + Environment |
| `100` | 4 | `cloud.values.yaml` | Cloud-specific |
| `101` | 5 | `cloud-environment.values.yaml` | Cloud + Environment |
| `110` | 6 | `cloud-account.values.yaml` | Cloud + Account |
| `111` | 7 | `cloud-account-environment.values.yaml` | All components (most specific) |

:::note Override Hierarchy
Configuration files are loaded in ascending order (0→7), with each subsequent file overriding values from previous ones!
:::

## Best Practices

* Start general: Always begin with values.yaml for defaults
* Be selective: Only create configuration files for combinations you actually need
* Document overrides: Comment why specific values are overridden at each level
* Avoid duplication: Only include values that differ from lower-priority files
* Validate hierarchy: Regularly review the override chain to ensure it matches intentions

## Conclusion

This binary-based configuration system provides a robust, scalable, and intuitive approach to managing complex configuration hierarchies. The mathematical foundation ensures consistency while the clear naming convention maintains readability and maintainability.
