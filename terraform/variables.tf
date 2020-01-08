variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "key_name" {
  default = "ssh-tunnel"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

