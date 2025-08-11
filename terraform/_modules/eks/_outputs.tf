output "oidc_url" {
  value = try(module.eks.oidc_provider,"")
}

output "oidc_arn" {
  value = try(module.eks.oidc_provider_arn,"")
}

output "cluster_endpoint" {
  value = try(module.eks.cluster_endpoint, "")
}

output "cluster_ca_certificate" {
  value = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  sensitive = true
}

output "node_group_iam_role_name" {
  value = try(module.eks.eks_managed_node_groups.main.iam_role_name, "")
}

output "node_group_iam_role_arn" {
  value = try(module.eks.eks_managed_node_groups.main.iam_role_arn, "")
}
