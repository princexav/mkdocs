# Environment Matrix

This page documents the HealthPulse multi-environment infrastructure, including network configuration, resource sizing, and access information.

---

## Environment Overview

| Environment | VPC CIDR | Task Size (CPU/Memory) | Desired Count | URL | Status |
|-------------|----------|----------------------|---------------|-----|--------|
| **DEV** | `10.1.0.0/16` | 256 CPU / 512 MB | 1 | _`dev.<your-domain>.com`_ | _Pending_ |
| **UAT** | `10.2.0.0/16` | 512 CPU / 1024 MB | 2 | _`uat.<your-domain>.com`_ | _Pending_ |
| **QA** | _`10.x.0.0/16`_ | _TBD_ | _TBD_ | _`qa.<your-domain>.com`_ | _Pending_ |
| **PROD** | `10.3.0.0/16` | 1024 CPU / 2048 MB | 2 | _`<your-domain>.com`_ | _Pending_ |

---

## AWS Resources Per Environment

### Networking

| Resource | DEV | UAT | QA | PROD |
|----------|-----|-----|-----|------|
| VPC | _vpc-xxxxxxxx_ | _vpc-xxxxxxxx_ | _vpc-xxxxxxxx_ | _vpc-xxxxxxxx_ |
| Public Subnets | _2_ | _2_ | _2_ | _2_ |
| Private Subnets | _2_ | _2_ | _2_ | _2_ |
| NAT Gateway | _1_ | _1_ | _1_ | _1_ |
| ALB DNS | _`<alb-dns>`_ | _`<alb-dns>`_ | _`<alb-dns>`_ | _`<alb-dns>`_ |

### Compute (ECS Fargate)

| Resource | DEV | UAT | QA | PROD |
|----------|-----|-----|-----|------|
| Cluster Name | _healthpulse-dev_ | _healthpulse-uat_ | _healthpulse-qa_ | _healthpulse-prod_ |
| Service Name | _hp-portal-dev_ | _hp-portal-uat_ | _hp-portal-qa_ | _hp-portal-prod_ |
| Task CPU | 256 | 512 | _TBD_ | 1024 |
| Task Memory | 512 MB | 1024 MB | _TBD_ | 2048 MB |
| Desired Count | 1 | 2 | _TBD_ | 2 |

### Kubernetes (EKS)

| Resource | Detail |
|----------|--------|
| Cluster Name | _healthpulse-eks_ |
| Node Count | _3_ |
| Namespaces | `healthpulse-dev`, `healthpulse-qa`, `healthpulse-prod` |
| kubectl Config | _`aws eks update-kubeconfig --name <cluster>`_ |

---

## Access Information

!!! warning "Security Notice"
    Never commit credentials, access keys, or sensitive URLs to this documentation. Use placeholders and share credentials via a secure channel (e.g., Ansible Vault, AWS Secrets Manager).

### DevOps Tools

| Tool | URL | Access Method |
|------|-----|---------------|
| Jenkins | _`http://<jenkins-ip>:8080`_ | _Username/Password_ |
| SonarQube | _`http://<sonar-ip>:9000`_ | _Username/Password_ |
| Ansible Tower | _`https://<tower-ip>`_ | _Username/Password_ |
| JFrog Artifactory | _`http://<artifactory-ip>:8082`_ | _Username/Password_ |
| Datadog | _`https://app.datadoghq.com`_ | _SSO / API Key_ |

### AWS Access

| Item | Value |
|------|-------|
| Region | _`us-east-1`_ |
| Account ID | _`xxxxxxxxxxxx`_ |
| Terraform State Bucket | _`healthpulse-terraform-state`_ |
| DynamoDB Lock Table | _`terraform-lock`_ |
| ECR Repository | _`healthpulse-portal`_ |

---

## Deployment Flow

```
DEV (automatic on develop branch)
 └──► UAT (automatic on release/* branch)
       └──► QA (manual trigger, approval required)
             └──► PROD (manual trigger, manager approval)
```
