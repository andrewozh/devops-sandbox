#!/usr/bin/env kcl

import yaml
import file
import manifests

# Load configuration
config_file_path = option("config_file", default="values.yaml")
full_config = yaml.decode(file.read(config_file_path))

# Extract config from kcl_app key or use full config as fallback
config = full_config.kcl_app if "kcl_app" in full_config else full_config

# Default values
name = config.name if "name" in config else "app"
namespace = config.namespace if "namespace" in config else "default"
replicas = config.replicaCount if "replicaCount" in config else 1

image_repo = config.image.repository if "image" in config and "repository" in config.image else "nginx"
image_tag = config.image.tag if "image" in config and "tag" in config.image else "latest"
image_pull_policy = config.image.pullPolicy if "image" in config and "pullPolicy" in config.image else "IfNotPresent"

service_type = config.service.type if "service" in config and "type" in config.service else "ClusterIP"
service_port = config.service.port if "service" in config and "port" in config.service else 80

resources = config.resources if "resources" in config else {}
node_selector = config.nodeSelector if "nodeSelector" in config else {}
tolerations = config.tolerations if "tolerations" in config else []
affinity = config.affinity if "affinity" in config else {}

# Generate Deployment
deployment = {
    apiVersion = "apps/v1"
    kind = "Deployment"
    metadata = {
        name = name
        namespace = namespace
        labels = {
            "app.kubernetes.io/name" = name
            "app.kubernetes.io/instance" = name
        }
    }
    spec = {
        replicas = replicas
        selector = {
            matchLabels = {
                "app.kubernetes.io/name" = name
                "app.kubernetes.io/instance" = name
            }
        }
        template = {
            metadata = {
                labels = {
                    "app.kubernetes.io/name" = name
                    "app.kubernetes.io/instance" = name
                }
            }
            spec = {
                serviceAccountName = name
                containers = [
                    {
                        name = name
                        image = "${image_repo}:${image_tag}"
                        imagePullPolicy = image_pull_policy
                        ports = [
                            {
                                name = "http"
                                containerPort = service_port
                                protocol = "TCP"
                            }
                        ]
                        resources = resources
                    }
                ]
                nodeSelector = node_selector
                tolerations = tolerations
                affinity = affinity
            }
        }
    }
}

# Generate Service
service = {
    apiVersion = "v1"
    kind = "Service" 
    metadata = {
        name = name
        namespace = namespace
        labels = {
            "app.kubernetes.io/name" = name
            "app.kubernetes.io/instance" = name
        }
    }
    spec = {
        type = service_type
        ports = [
            {
                port = service_port
                targetPort = "http"
                protocol = "TCP"
                name = "http"
            }
        ]
        selector = {
            "app.kubernetes.io/name" = name
            "app.kubernetes.io/instance" = name
        }
    }
}

# Generate ServiceAccount
serviceAccount = {
    apiVersion = "v1"
    kind = "ServiceAccount"
    metadata = {
        name = name
        namespace = namespace
        labels = {
            "app.kubernetes.io/name" = name
            "app.kubernetes.io/instance" = name
        }
    }
    automountServiceAccountToken = True
}

# Output clean YAML with proper document separators for ArgoCD
manifests.yaml_stream([deployment, service, serviceAccount])
