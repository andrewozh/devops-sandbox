variable "avoid_billing" {
  description = "Don't create resources that cost money"
  type        = bool
  default     = false
}

variable "env" {
  description = "The environment name"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets inside the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets inside the VPC"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of EKS cluster to add subnet tags"
  type        = string
  default     = ""
}

variable "tags_all" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
