module "vpc_peering" {
  source = "cloudposse/vpc-peering/aws"
  version = "1.0.0"

  auto_accept                               = true
  requestor_allow_remote_vpc_dns_resolution = true
  acceptor_allow_remote_vpc_dns_resolution  = true

  requestor_vpc_id = var.requestor_vpc_id
  acceptor_vpc_id  = var.acceptor_vpc_id

  tags = var.tags_all
}
