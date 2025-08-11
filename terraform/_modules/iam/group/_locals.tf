locals {
  groups_map = { for group in var.groups : group.name => group }
}
