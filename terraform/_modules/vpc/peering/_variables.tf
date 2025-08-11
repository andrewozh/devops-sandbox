variable "avoid_billing" {
  description = "Don't create resources that cost money"
  type        = bool
  default     = false
}

variable "requestor_vpc_id" {
  type = string
}
variable "acceptor_vpc_id" {
  type = string
}

variable "tags_all" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
