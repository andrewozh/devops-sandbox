locals {
  aws_region = "global"

  tags = {
    Region  = local.aws_region
  }
}
