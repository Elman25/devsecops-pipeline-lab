terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Flaw 1: Exposes SSH (Port 22) directly to 0.0.0.0/0
resource "aws_security_group" "vps_sg" {
  name        = "vps-security-group"
  description = "Security group for hardened VPS server"

  ingress {
    description = "Allow SSH from anywhere (CRITICAL RISK)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Flaw 2: Unencrypted storage & IMDSv1 enabled
resource "aws_instance" "vps_node" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.vps_sg.name]

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    encrypted   = false
  }

  metadata_options {
    http_tokens = "optional"
  }

  tags = {
    Name = "devsecops-vps-node"
  }
}
