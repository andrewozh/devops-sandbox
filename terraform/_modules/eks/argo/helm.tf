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

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"

  create_namespace = true
  namespace        = var.argo_namespace
  version          = var.argo_chart_version

  values = [
    <<-EOT
    ---
    global:
      image:
        tag: "${var.argo_version}"
    dex:
      enabled: false
    server:
      extraArgs:
        - --insecure
    EOT
  ]
}
