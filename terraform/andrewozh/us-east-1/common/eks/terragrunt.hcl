include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/eks"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  dependency_vpc = "${dirname(find_in_parent_folders("env.hcl"))}/vpc"
}

dependency "vpc" {
  config_path = local.dependency_vpc
}

dependencies {
  paths = [
    local.dependency_vpc,
  ]
}

inputs = {
  cluster_name             = local.environment_vars.locals.eks_cluster_name
  region                   = local.region_vars.locals.aws_region
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnets                  = dependency.vpc.outputs.private_subnets
  
  avoid_billing = local.account_vars.locals.avoid_billing

  tags_all = merge(
    local.account_vars.locals.tags,
    local.region_vars.locals.tags,
    local.environment_vars.locals.tags
  )
}
