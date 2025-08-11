locals {
  environment = "common"

  eks_cluster_name = "eks-${local.environment}"

  tags = {
    Environment  = local.environment
  }
}
