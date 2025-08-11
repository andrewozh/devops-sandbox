provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca_certificate

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["--profile", "andrewozh", "eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

data "aws_ecrpublic_authorization_token" "token" {}

resource "helm_release" "karpenter" {
  namespace        = var.karpenter_namespace
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = var.karpenter_chart_version

  values = [
    <<-EOT
    replicas: 1
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${var.cluster_endpoint}
      interruptionQueueName: ${module.karpenter.queue_name}
      defaultInstanceProfile: ${module.karpenter.instance_profile_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}
    EOT
  ]

  lifecycle {
    ignore_changes = [repository_password]
  }

  depends_on = [
    module.karpenter
  ]
}
