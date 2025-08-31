---
tags:
- article
- platform
- infrastructure
---

# Configuration Files Ordering System

## Overview

This document describes a binary-based configuration file ordering system inspired by Linux file permissions. The system provides a predictable and logical way to manage configuration overrides from the most general to the most specific settings.

## Core Concept

The system uses a 3-bit binary representation where each bit position represents a configuration scope:

- **Bit 2 (MSB)**: Cloud (weight: 4)
- **Bit 1**: Account (weight: 2)  
- **Bit 0 (LSB)**: Environment (weight: 1)

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

## Override Hierarchy

Configuration files are loaded in ascending order (0→7), with each subsequent file overriding values from previous ones:

```
values.yaml (000)
    ↓ overridden by
environment.values.yaml (001)
    ↓ overridden by
account.values.yaml (010)
    ↓ overridden by
account-environment.values.yaml (011)
    ↓ overridden by
cloud.values.yaml (100)
    ↓ overridden by
cloud-environment.values.yaml (101)
    ↓ overridden by
cloud-account.values.yaml (110)
    ↓ overridden by
cloud-account-environment.values.yaml (111)
```

## Benefits

### 1. **Predictability**
The binary representation makes the loading order immediately clear and mathematically deterministic.

### 2. **Scalability**
Easy to extend by adding more bits for additional configuration scopes (e.g., region, team, service).

### 3. **Clarity**
File naming convention directly reflects what scopes are included, making it intuitive to understand what each file configures.

### 4. **Granular Control**
Allows precise configuration at any combination of scopes without redundancy.

## Example Use Case

Consider a multi-cloud deployment scenario:

1. **Base configuration** (`values.yaml`): Default settings for all deployments
2. **Production environment** (`environment.values.yaml`): Production-specific settings
3. **Enterprise account** (`account.values.yaml`): Enterprise tier features
4. **AWS cloud provider** (`cloud.values.yaml`): AWS-specific configurations
5. **AWS production** (`cloud-environment.values.yaml`): AWS production optimizations
6. **Final override** (`cloud-account-environment.values.yaml`): Most specific settings for AWS enterprise production

## Implementation Example

```yaml
# values.yaml (000) - Base configuration
database:
  type: postgresql
  port: 5432
  maxConnections: 100

# environment.values.yaml (001) - Production environment
database:
  maxConnections: 500  # Override for production load

# cloud.values.yaml (100) - AWS specific
database:
  type: aurora-postgresql  # Override for AWS Aurora

# cloud-environment.values.yaml (101) - AWS Production
database:
  maxConnections: 1000  # Final override for AWS production
```

## Calculating File Priority

To determine which configuration file to use or create:

1. Assign binary positions:

* Cloud specified? Set bit 2 (value: 4)
* Account specified? Set bit 1 (value: 2)
* Environment specified? Set bit 0 (value: 1)

2. Sum the values to get the priority order

**Example:** Cloud + Environment = 4 + 1 = 5 = 101 binary = cloud-environment.values.yaml

## Best Practices

* Start general: Always begin with values.yaml for defaults
* Be selective: Only create configuration files for combinations you actually need
* Document overrides: Comment why specific values are overridden at each level
* Avoid duplication: Only include values that differ from lower-priority files
* Validate hierarchy: Regularly review the override chain to ensure it matches intentions

## Conclusion

This binary-based configuration system provides a robust, scalable, and intuitive approach to managing complex configuration hierarchies. The mathematical foundation ensures consistency while the clear naming convention maintains readability and maintainability.
