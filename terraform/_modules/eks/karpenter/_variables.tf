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

variable "irsa_oidc_provider_arn" {
  description = "The OIDC provider ARN"
  type        = string
}

variable "iam_role_arn" {
  description = "The IAM role ARN"
  type        = string
}

variable "iam_role_name" {
  description = "The IAM role name"
  type        = string
}

variable "karpenter_namespace" {
  description = "The K8S namespace to deploy Karpenter into"
  default     = "karpenter"
  type        = string
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version to be installed"
  type        = string
  default     = "v0.33.0"
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
