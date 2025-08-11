locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region == "global" ? "us-east-1" : local.region_vars.locals.aws_region
}

generate "provider" {
  path      = "terragrunt_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.account_name}"
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

generate "versions" {
  path      = "terragrunt_versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("versions.tf")
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terragrunt-${local.account_name}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
    profile        = "${local.account_name}"
  }
  generate = {
    path      = "terragrunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
