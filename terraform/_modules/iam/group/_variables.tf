variable "users" {
  description = "Users in groups"
  type = list(object({
    name   = string
    groups = list(string)
  }))
}

variable "groups" {
  description = "Groups to create"
  type = list(object({
    name       = string
    policy_arns = list(string)
  }))
}
