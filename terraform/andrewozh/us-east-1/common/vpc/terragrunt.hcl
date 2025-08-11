include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/vpc"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public_subnets  = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]

  env          = local.environment_vars.locals.environment
  cluster_name = local.environment_vars.locals.eks_cluster_name

  tags_all = merge(
    local.account_vars.locals.tags,
    local.region_vars.locals.tags,
    local.environment_vars.locals.tags
  )
}
