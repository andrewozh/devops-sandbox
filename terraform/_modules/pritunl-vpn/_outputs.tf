output "elastic_ip" {
  value = aws_eip.pritunl.public_ip
}
