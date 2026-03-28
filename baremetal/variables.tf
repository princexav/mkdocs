# =============================================================
#  HealthPulse Portal — Bare-Metal Variables
# =============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "healthpulse"
}

variable "team_name" {
  description = "Team name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, uat, prod)"
  type        = string
  default     = "dev"
}

# ─────────────── NETWORKING ───────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

# ─────────────── COMPUTE ───────────────
variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID (find at https://cloud-images.ubuntu.com/locator/ec2/)"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10
}

# ─────────────── ACCESS ───────────────
variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH (restrict to your IP)"
  type        = string
  default     = "0.0.0.0/0"
}
