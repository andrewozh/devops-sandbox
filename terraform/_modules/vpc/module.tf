data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vpc-${var.env}"

  enable_nat_gateway   = var.avoid_billing ? false : true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  azs             = data.aws_availability_zones.available.names

  public_subnet_tags = {
    "Name"                                      = "sn-${var.env}-public"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "Name"                                      = "sn-${var.env}-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    "karpenter.sh/discovery"                    = var.cluster_name
  }

  public_route_table_tags = {
    Name = "rt-${var.env}-public"
  }

  private_route_table_tags = {
    Name = "rt-${var.env}-private"
  }

  tags = merge(
    var.tags_all,
    {
      Name = "vpc-${var.env}"
    },
  )
}

# module "vpc_endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = "3.0.0"
#   count   = local.enable_endpoints
#
#   vpc_id             = module.vpc.vpc_id
#   security_group_ids = [aws_security_group.ep_sg.id]
#   tags               = local.default-tags
#
#   endpoints = {
#     s3 = {
#       service = "s3"
#       tags    = { Name = "s3-vpc-endpoint" }
#     },
#     ssm = {
#       service             = "ssm"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ssmmessages = {
#       service             = "ssmmessages"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     lambda = {
#       service             = "lambda"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecs = {
#       service             = "ecs"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecs_telemetry = {
#       service             = "ecs-telemetry"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ec2 = {
#       service             = "ec2"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ec2messages = {
#       service             = "ec2messages"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecr_api = {
#       service             = "ecr.api"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       //policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     ecr_dkr = {
#       service             = "ecr.dkr"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       //policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     kms = {
#       service             = "kms"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     codedeploy = {
#       service             = "codedeploy"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     codedeploy_commands_secure = {
#       service             = "codedeploy-commands-secure"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     logs = {
#       service             = "logs"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     sts = {
#       service             = "sts"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     elasticloadbalancing = {
#       service             = "elasticloadbalancing"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     autoscaling = {
#       service             = "autoscaling"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     appmesh-envoy-management = {
#       service             = "appmesh-envoy-management"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     }
#   }
# }
