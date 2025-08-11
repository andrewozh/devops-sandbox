include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/eks/argo"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  dependency_eks = "${dirname(find_in_parent_folders("env.hcl"))}/eks"
}

dependency "eks" {
  config_path = local.dependency_eks
}

dependencies {
  paths = [
    local.dependency_eks,
  ]
}

inputs = {
  avoid_billing = local.account_vars.locals.avoid_billing

  cluster_name           = local.environment_vars.locals.eks_cluster_name
  cluster_endpoint       = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.eks.outputs.cluster_ca_certificate

  tags = merge(
    local.account_vars.locals.tags,
    local.region_vars.locals.tags,
    local.environment_vars.locals.tags
  )
}
