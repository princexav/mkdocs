# =============================================================
#  HealthPulse Portal — DNS (Route 53) Variables
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

# ─────────────── DOMAIN ───────────────
variable "domain_name" {
  description = "Root domain name (e.g. team-healthpulse.com)"
  type        = string
}

# ─────────────── INFRASTRUCTURE IPs ───────────────
# These come from your other Terraform outputs.
# Run: cd ../baremetal && terraform output public_ip
# Run: cd ../k3s && terraform output master_public_ip

variable "baremetal_ip" {
  description = "Elastic IP of the bare-metal Nginx server (from terraform/baremetal output)"
  type        = string
}

variable "k3s_master_ip" {
  description = "Elastic IP of the k3s master node (from terraform/k3s output)"
  type        = string
}
