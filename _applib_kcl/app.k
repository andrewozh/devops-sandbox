# 🚀 KCL + YAML Hybrid Application Generator
# Support command-line arguments: kcl app.k -D env=development -D replicas=5

import yaml
import file

# 📝 Configuration overrides (use -D key=value to override)
env = option("env", default="production")
replicas = option("replicas", default=0)
image_tag = option("image_tag", default="")
namespace = option("namespace", default="")
config_file = option("config_file", default="")             

# 🔧 Load configuration based on environment or custom file
configPath = config_file if config_file else ("examples/development.yaml" if env == "development" else ("values.yaml" if env == "default" else "examples/production.yaml"))
baseConfig = yaml.decode(file.read(configPath))

# 🎯 Apply command-line overrides
config = baseConfig | {
    environment = env
    namespace = namespace if namespace else (baseConfig.namespace if "namespace" in baseConfig else env if env != "default" else "default")
    replicaCount = replicas if replicas > 0 else (baseConfig.replicaCount if "replicaCount" in baseConfig else 1)
    image = (baseConfig.image if "image" in baseConfig else {"repository": "nginx", "tag": "latest"}) | ({"tag" = image_tag} if image_tag else {})
    name = (baseConfig.name if "name" in baseConfig else "app") + ("-${env}" if env not in ["production", "default"] else "")
}

# 🏗️ Generate Kubernetes Resources

# Deployment
deployment = {
    apiVersion = "apps/v1"
    kind = "Deployment"
    metadata = {
        name = config.name
        namespace = config.namespace
        labels = {
            "app.kubernetes.io/name" = config.name
            "app.kubernetes.io/instance" = config.name
            "app.kubernetes.io/environment" = config.environment
            "app.kubernetes.io/managed-by" = "kcl-hybrid"
        }
    }
    spec = {
        replicas = config.replicaCount
        selector = {
            matchLabels = {
                "app.kubernetes.io/name" = config.name
                "app.kubernetes.io/instance" = config.name
            }
        }
        template = {
            metadata = {
                labels = {
                    "app.kubernetes.io/name" = config.name
                    "app.kubernetes.io/instance" = config.name
                    "app.kubernetes.io/environment" = config.environment
                }
            }
            spec = {
                serviceAccountName = config.name
                containers = [
                    {
                        name = config.name
                        image = "${config.image.repository}:${config.image.tag}"
                        imagePullPolicy = config.image.pullPolicy if "pullPolicy" in config.image else "IfNotPresent"
                        ports = [
                            {
                                name = "http"
                                containerPort = config.service.port
                                protocol = "TCP"
                            }
                        ]
                        resources = config.resources if "resources" in config else {}
                    }
                ]
                nodeSelector = config.nodeSelector if "nodeSelector" in config else {}
            }
        }
    }
}

# Service
service = {
    apiVersion = "v1"
    kind = "Service"
    metadata = {
        name = config.name
        namespace = config.namespace
        labels = {
            "app.kubernetes.io/name" = config.name
            "app.kubernetes.io/instance" = config.name
        }
    }
    spec = {
        type = config.service.type if "type" in config.service else "ClusterIP"
        ports = [
            {
                port = config.service.port
                targetPort = "http"
                protocol = "TCP"
                name = "http"
            }
        ]
        selector = {
            "app.kubernetes.io/name" = config.name
            "app.kubernetes.io/instance" = config.name
        }
    }
}

# ServiceAccount
serviceAccount = {
    apiVersion = "v1"
    kind = "ServiceAccount"
    metadata = {
        name = config.name
        namespace = config.namespace
        labels = {
            "app.kubernetes.io/name" = config.name
            "app.kubernetes.io/instance" = config.name
        }
    }
    automountServiceAccountToken = True
}

# 📦 Generated manifests 
manifests = [
    deployment,
    service,
    serviceAccount
]

# 🎉 Summary with CLI arguments
summary = {
    title = "🚀 YAML + KCL Hybrid with CLI Arguments"
    message = "Generated Kubernetes manifests with command-line configuration overrides"
    
    cliArguments = {
        env = env
        configFile = config_file if config_file else "auto-detected from env"
        customNamespace = namespace if namespace else "using config default"
        customReplicas = replicas if replicas > 0 else "using config default"
        customImageTag = image_tag if image_tag else "using config default"
    }
    
    resolvedConfig = {
        configSource = configPath
        name = config.name
        namespace = config.namespace
        environment = config.environment
        replicaCount = config.replicaCount
        image = "${config.image.repository}:${config.image.tag}"
        serviceType = config.service.type if "type" in config.service else "ClusterIP"
    }
    
    generatedResources = {
        count = len(manifests)
        types = [manifest.kind for manifest in manifests]
    }
    
    usageExamples = [
        "# Basic usage"
        "kcl app.k                                       # Production config (default)"
        "kcl app.k -D env=development                    # Development config"
        "kcl app.k -D env=default                        # Default values.yaml"
        ""
        "# Override specific values"
        "kcl app.k -D replicas=5                         # Override replicas"
        "kcl app.k -D image_tag=v2.0.0                   # Override image tag"
        "kcl app.k -D namespace=staging                  # Override namespace"
        ""
        "# Multiple overrides"
        "kcl app.k -D env=development -D replicas=2 -D namespace=dev-test"
        ""
        "# Custom config file"
        "kcl app.k -D config_file=staging.yaml           # Use custom config"
        ""
        "# Alternative: Use option arguments"
        "kcl app.k --env development"
        "kcl app.k --replicas 5 --image_tag v2.0.0"
    ]
}