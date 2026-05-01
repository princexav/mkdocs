# =============================================================
#  HealthPulse Portal — DNS Outputs
# =============================================================

output "nameservers" {
  description = "Route 53 nameservers — update your domain registrar with these"
  value       = aws_route53_zone.main.name_servers
}

output "zone_id" {
  description = "Route 53 Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "domain_name" {
  description = "Root domain"
  value       = var.domain_name
}

output "urls" {
  description = "All configured URLs"
  value = {
    root      = "http://${var.domain_name}"
    baremetal = "http://baremetal.${var.domain_name}"
    k8s       = "http://k8s.${var.domain_name}"
    dev       = "http://dev.${var.domain_name}"
    uat       = "http://uat.${var.domain_name}"
    prod      = "http://prod.${var.domain_name}"
  }
}

output "registrar_instructions" {
  description = "Next step after terraform apply"
  value       = "Update your domain registrar's nameservers to: ${join(", ", aws_route53_zone.main.name_servers)}"
}
