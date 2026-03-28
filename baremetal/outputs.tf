# =============================================================
#  HealthPulse Portal — Bare-Metal Outputs
# =============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.baremetal.id
}

output "subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.web.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.web.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/id_ed25519.pub ubuntu@${aws_eip.web.public_ip}"
}

output "deploy_path" {
  description = "Path to deploy built files"
  value       = "/var/www/healthpulse"
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web.id
}
