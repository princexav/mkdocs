# =============================================================
#  HealthPulse Portal — k3s Cluster Variables
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
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

# ─────────────── COMPUTE ───────────────
variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS us-east-1
}

variable "master_instance_type" {
  description = "EC2 instance type for k3s master"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 instance type for k3s workers"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Number of k3s worker nodes"
  type        = number
  default     = 2
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

# ─────────────── ACCESS ───────────────
variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH and access K8s API (restrict to your IP)"
  type        = string
  default     = "0.0.0.0/0"
}
