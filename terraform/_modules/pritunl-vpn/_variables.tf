variable "aws_key_name" {
  type        = string
  description = "SSH keypair name for VPN instance"
}

variable "public_subnet_id" {
  type        = string
  description = "One of the public subnet id for the VPN instance"
}

variable "admin_cidrs" {
  description = "List CIDRs allowed SSH and HTTPS access to manage console"
  type        = list(string)
  default     = []
}

variable "user_cidrs" {
  description = "List CIDRs allowed HTTPS access to manage console"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

variable "volume_size" {
  type        = number
  description = "EC2 volume size"
  default     = 10
}

variable "volume_extra_tags" {
  type        = map(string)
  sensitive   = false
  description = "AWS tags for EC2 root block storage"
  default     = {}
}

variable "tags" {
  type        = map(string)
  sensitive   = false
  description = "AWS tags"
  default     = {}
}
