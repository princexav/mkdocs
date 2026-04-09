# =============================================================
#  HealthPulse Portal — k3s Cluster Outputs
# =============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.k3s.id
}

output "master_public_ip" {
  description = "Master node Elastic IP"
  value       = aws_eip.master.public_ip
}

output "master_private_ip" {
  description = "Master node private IP"
  value       = aws_instance.master.private_ip
}

output "worker_public_ips" {
  description = "Worker node public IPs"
  value       = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Worker node private IPs"
  value       = aws_instance.worker[*].private_ip
}

output "ssh_master" {
  description = "SSH command to connect to master"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.master.public_ip}"
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig from master"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.master.public_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml' | sed 's/127.0.0.1/${aws_eip.master.public_ip}/g' > ~/.kube/healthpulse-config"
}

output "kubectl_test" {
  description = "Test kubectl from master"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.master.public_ip} 'sudo k3s kubectl get nodes'"
}

output "k3s_token" {
  description = "k3s cluster join token"
  value       = random_password.k3s_token.result
  sensitive   = true
}
