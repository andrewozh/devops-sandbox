resource "aws_security_group" "pritunl" {
  name        = "pritunl-vpn"
  description = "Security Group for pritunl-vpn instance"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH from inner network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(var.admin_cidrs, [data.aws_vpc.selected.cidr_block])
  }

  ingress {
    description = "HTTPS for specific CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.user_cidrs
  }

  ingress {
    description = "Port for VPN users"
    from_port   = 17971
    to_port     = 17971
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  egress {
    description = "Any outbound traffic to internet"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }

  tags = var.tags
}
