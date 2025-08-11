data "aws_ami" "oracle" {
  most_recent = true

  filter {
    name   = "name"
    values = ["OL8.5-x86_64-HVM-2021-11-24"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["131827586825"] # Oracle
}

data "aws_subnet" "selected" {
  id = var.public_subnet_id
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_route53_zone" "selected" {
  name = "drct.aero"
}

data "aws_caller_identity" "current" {}
