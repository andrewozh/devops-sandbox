---
tags:
- category
- cloud
- infrastructure
---

# Cloud infra

Modern cloud infrastructure leverages managed services across multiple layers to achieve scalability, security, and operational efficiency. At the foundation, organizations establish **secure networking (VPC + VPN)** with centralized **access management** and **DNS routing**, while containerized applications run on **managed Kubernetes** services with automatic scaling and **load balancing**. Data managed through dedicated **storage services** and encrypted **secret management** systems.

## VPN

For secure access to hosts in private subnets, setting up a VPN is essential. Here are guides to get started:

* [Setup Pritunl VPN on EC2](vpn)

## Essential Cloud Services

Here's the check list of cloud services to learn and notedown here:

| Service | AWS 🔄 | GCP | Azure |
|---------|-----|-----|-------|
| **Access Management** | IAM | IAM | Active Directory, Azure AD |
| **Cloud Networking** | VPC | VPC | Virtual Network |
| **Cloud DNS** | Route 53 | Cloud DNS | Azure DNS |
| **TLS/SSL Certificates** | ACM | Certificate Manager | App Service Certificates |
| **Kubernetes** | EKS | GKE | AKS |
| **Load Balancers** | ELB, ALB, NLB, Gateway | Cloud Load Balancing | Load Balancer, Application Gateway |
| **Container Registry** | ECR | Container Registry, Artifact Registry | Container Registry |
| **Storage** | S3, EFS, EBS | Cloud Storage, Filestore, Persistent Disk | Blob Storage, Azure Files, Disk Storage |
| **Secret Management** | SSM, Secrets Manager | Secret Manager | Key Vault |
| **Key Management** | KMS | Cloud KMS | Key Vault |
| **CDN** | CloudFront | Cloud CDN | Azure CDN |
| **Serverless** | Lambda, API Gateway | Cloud Functions, API Gateway | Functions, API Management |

