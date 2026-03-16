# HealthPulse DevOps Documentation

Welcome to the **HealthPulse Portal** DevOps documentation site. This documentation is maintained as code — Markdown files in Git, built with MkDocs Material, and served via Docker.

---

## Project Overview

**HealthPulse Inc.** is a healthcare technology startup that has built a patient portal as a React/TypeScript single-page application. The DevOps team is responsible for designing and implementing a complete CI/CD pipeline, multi-environment infrastructure, container orchestration, and observability platform on AWS.

| Item | Detail |
|------|--------|
| **Application** | HealthPulse Patient Portal |
| **Tech Stack** | React 18, TypeScript, Vite, Tailwind CSS |
| **Cloud Provider** | AWS (ECS Fargate, EKS, ALB, VPC, Route 53) |
| **CI/CD** | Jenkins / GitLab CI / Azure DevOps |
| **Monitoring** | Datadog |

---

## Team Roster

<!-- Update this table with your team members -->

| Name | Role | Email | GitHub Handle |
|------|------|-------|---------------|
| _Team Member 1_ | _DevOps Lead_ | _email@example.com_ | _@handle_ |
| _Team Member 2_ | _Cloud Engineer_ | _email@example.com_ | _@handle_ |
| _Team Member 3_ | _CI/CD Engineer_ | _email@example.com_ | _@handle_ |
| _Team Member 4_ | _SRE / Monitoring_ | _email@example.com_ | _@handle_ |

---

## Quick Links

| Resource | Link |
|----------|------|
| Architecture Decisions | [ADRs](architecture.md) |
| Environment Matrix | [Environments](environments.md) |
| Runbooks | [Operational Runbooks](runbooks.md) |
| CI/CD Pipeline | [Pipeline Docs](pipeline.md) |
| Application Repo | _`<link to HealthPulse_App repo>`_ |
| Deployment Repo | _`<link to HealthPulse_Deployment repo>`_ |
| Datadog Dashboard | _`<link to Datadog>`_ |
| SonarQube | _`<link to SonarQube>`_ |
| Artifactory | _`<link to JFrog Artifactory>`_ |

---

## Getting Started

```bash
# Clone the deployment repository
git clone <your-deployment-repo-url>
cd healthpulse-capstone

# Start the docs site locally (dev mode with live reload)
cd docs && docker-compose up docs-dev
# Docs available at http://localhost:8084

# Build and serve docs (production mode)
cd docs && docker-compose up docs-prod
# Docs available at http://localhost:84
```
