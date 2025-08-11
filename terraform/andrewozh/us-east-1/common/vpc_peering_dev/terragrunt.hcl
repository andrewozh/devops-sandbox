include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/vpc/peering"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  dependency_vpc_this = "${dirname(find_in_parent_folders("env.hcl"))}/vpc"
  dependency_vpc_dev  = "${dirname(find_in_parent_folders("region.hcl"))}/dev/vpc"
}

dependency "vpc_this" {
  config_path = local.dependency_vpc_this
}

dependency "vpc_peer" {
  config_path = local.dependency_vpc_dev
}

dependencies {
  paths = [
    local.dependency_vpc_this,
    local.dependency_vpc_dev
  ]
}

inputs = {
  requestor_vpc_id = dependency.vpc_this.outputs.vpc_id
  acceptor_vpc_id  = dependency.vpc_peer.outputs.vpc_id
}
