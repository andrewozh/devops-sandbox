#tfsec:ignore:aws-ec2-enable-at-rest-encryption
resource "aws_instance" "pritunl" {
  ami                    = data.aws_ami.oracle.id
  instance_type          = var.instance_type
  key_name               = var.aws_key_name
  user_data              = file("${path.module}/user_data.sh")
  vpc_security_group_ids = [aws_security_group.pritunl.id]
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.pritunl.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  provisioner "file" {
    content     = <<EOT
[profile pritunl]
role_arn = ${aws_iam_role.pritunl.arn}
credential_source = Ec2InstanceMetadata
EOT
    destination = "/home/ec2-user/.aws/config"
  }

  provisioner "file" {
    content     = file("${path.module}/renew-cert.sh")
    destination = "/home/ec2-user/certbot/renew-cert.sh"
  }

  root_block_device {
    volume_size           = var.volume_size
    delete_on_termination = false
    tags                  = merge(var.tags, var.volume_extra_tags)
  }

  tags = var.tags
}

resource "aws_eip" "pritunl" {
  instance = aws_instance.pritunl.id
  vpc      = true
  tags     = var.tags
}
