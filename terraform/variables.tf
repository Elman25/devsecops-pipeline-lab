variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS deployment region"
}

variable "admin_cidr" {
  type        = string
  default     = "192.0.2.1/32" # Restricts SSH to explicit management IP
  description = "Trusted CIDR block for administrative SSH access"
}

variable "ami_id" {
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
  description = "Base AMI ID"
}
