include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/iam/user"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  users = [ for user in local.account_vars.locals.users : user.name ]

  tags_all = merge(
    local.account_vars.locals.tags,
    local.region_vars.locals.tags,
  )
}

inputs = {
  base_source_url = "terraform-aws-modules/iam/aws//modules/iam-user?version=5.32.0"
  users           = local.users
}
