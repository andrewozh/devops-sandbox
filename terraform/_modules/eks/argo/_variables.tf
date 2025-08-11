variable "avoid_billing" {
  description = "Don't create resources that cost money"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate of the cluster"
  type        = string
}

variable "argo_namespace" {
  description = "The K8S namespace to deploy ArgoCD into"
  type        = string
  default     = "argocd"
}

variable "argo_chart_version" {
  description = "ArgoCD Helm chart version to be installed"
  type        = string
  default     = "3.35.4"
}

variable "argo_version" {
  description = "ArgoCD version to be installed"
  type        = string
  default     = "v2.6.6"
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
