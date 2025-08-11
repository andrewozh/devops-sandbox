include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/iam/group"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  tags_all = merge(
    local.account_vars.locals.tags,
    local.region_vars.locals.tags,
  )
}

inputs = {
  groups = local.account_vars.locals.groups
  users  = local.account_vars.locals.users
}
