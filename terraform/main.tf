# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

provider "http" {
}

# Create a VPC to launch our instances into
resource "aws_vpc" "multiarch" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.multiarch.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.multiarch.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "multiarch" {
  vpc_id                  = aws_vpc.multiarch.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "multiarch2" {
  vpc_id                  = aws_vpc.multiarch.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "multiarch" {
  name        = "multiarch"
  description = "SSH Tunnel"
  vpc_id      = aws_vpc.multiarch.id

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [local.workstation-external-cidr]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "multiarch" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    agent       = "false"
    private_key = file(var.private_key_path)
  }

  instance_type          = "a1.medium"
  ami                    = data.aws_ami.amazon-linux-2.id
  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.multiarch.id]
  subnet_id              = aws_subnet.multiarch.id
  monitoring             = true

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com | sh",
      "sudo usermod -aG docker ubuntu"
    ]
  }
}

data "aws_subnet_ids" "subnet_ids" {
  depends_on = [aws_subnet.multiarch2, aws_subnet.multiarch]
  vpc_id = aws_vpc.multiarch.id
}

output "net_subnet_ids" {
  value = tolist(data.aws_subnet_ids.subnet_ids.ids)[0]
}

output "VPCI_ID" {
  value = aws_vpc.multiarch.id
}

output "SSH_Command" {
  value = "autossh -M 0 ubuntu@${aws_instance.multiarch.public_ip}"
}

output "SSHuttle_Command" {
  value = "sshuttle -e 'autossh -M 0' --dns -NHr ubuntu@${aws_instance.multiarch.public_ip} 0/0"
}

