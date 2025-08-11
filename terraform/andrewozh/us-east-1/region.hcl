locals {
  aws_region = "us-east-1"

  tags = {
    Region  = local.aws_region
  }
}
