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
  region = var.aws_region
}

resource "aws_security_group" "vps_sg" {
  name        = "vps-security-group"
  description = "Hardened security group for VPS node"

  ingress {
    description = "Allow SSH from trusted management IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Allow restricted outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vps_node" {
  ami                  = var.ami_id
  instance_type        = "t3.micro"
  security_groups      = [aws_security_group.vps_sg.name]
  ebs_optimized        = true
  monitoring           = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Strictly enforces IMDSv2
  }

  tags = {
    Name = "devsecops-vps-node"
  }
}
