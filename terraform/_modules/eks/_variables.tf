variable "avoid_billing" {
  description = "Don't create resources that cost money"
  type        = bool
  default     = false
}

variable "cluster_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "region" {
  type = string
}

variable "subnets" {
  description = "The list of subnet IDs to deploy your EKS cluster"
  type        = list(string)
  default     = null
}

variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.28"
}

variable "policy_arns" {
  description = "A list of policy ARNs to attach the node groups role"
  type        = list(string)
  default     = []
}

variable "main_instance_type" {
  type = string
  default = "t3.xlarge"
}
variable "main_instance_count" {
  type = number
  default = 1
}

variable "tags_all" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
