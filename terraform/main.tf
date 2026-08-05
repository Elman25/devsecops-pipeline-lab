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

# Fix CKV2_AWS_41: IAM Role & Instance Profile for EC2
resource "aws_iam_role" "vps_role" {
  name = "devsecops-vps-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "vps_profile" {
  name = "devsecops-vps-instance-profile"
  role = aws_iam_role.vps_role.name
}

# Security Group
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

  # Fix CKV_AWS_382: Restrict egress to explicit outbound ports instead of protocol "-1"
  egress {
    description = "Allow outbound HTTPS traffic for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound HTTP traffic for package downloads"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Hardened Instance
resource "aws_instance" "vps_node" {
  ami                  = var.ami_id
  instance_type        = "t3.micro"
  security_groups      = [aws_security_group.vps_sg.name]
  iam_instance_profile = aws_iam_instance_profile.vps_profile.name
  ebs_optimized        = true
  monitoring           = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 enforced
  }

  tags = {
    Name = "devsecops-vps-node"
  }
}
