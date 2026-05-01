# =============================================================
#  HealthPulse Portal — DNS (Route 53)
#  Hosted zone + A records for bare-metal and k3s
# =============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "HealthPulse"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = var.team_name
    }
  }
}

# ─────────────── HOSTED ZONE ───────────────
# This creates the DNS zone in Route 53.
# After creation, you must update your domain registrar's
# nameservers to point to the NS records shown in the output.
resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "HealthPulse Portal — managed by Terraform"

  tags = {
    Name = "${var.project_name}-${var.environment}-zone"
  }
}

# ─────────────── ROOT DOMAIN ───────────────
# team-healthpulse.com → k3s master (production)
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [var.k3s_master_ip]
}

# ─────────────── BARE-METAL SUBDOMAIN ───────────────
# baremetal.team-healthpulse.com → bare-metal Nginx server
resource "aws_route53_record" "baremetal" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "baremetal.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.baremetal_ip]
}

# ─────────────── K8S SUBDOMAIN ───────────────
# k8s.team-healthpulse.com → k3s master
resource "aws_route53_record" "k8s" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "k8s.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.k3s_master_ip]
}

# ─────────────── ENVIRONMENT SUBDOMAINS ───────────────
# dev.team-healthpulse.com → bare-metal (Task G deployment)
resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dev.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.baremetal_ip]
}

# uat.team-healthpulse.com → k3s master (UAT namespace)
resource "aws_route53_record" "uat" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "uat.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.k3s_master_ip]
}

# prod.team-healthpulse.com → k3s master (prod namespace)
resource "aws_route53_record" "prod" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "prod.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.k3s_master_ip]
}

# ─────────────── WILDCARD (OPTIONAL) ───────────────
# *.team-healthpulse.com → k3s master
# Catches any subdomain not explicitly defined above.
# Useful with Traefik ingress on k3s — route by hostname.
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.k3s_master_ip]
}
