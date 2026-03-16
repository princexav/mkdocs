# Operational Runbooks

This page contains step-by-step runbooks for common operational procedures. Each runbook follows a standard format with description, prerequisites, steps, verification, and escalation.

---

## Runbook 1: Deploying a New Version

### Description

Deploy a new version of the HealthPulse Portal application to a target environment using the CI/CD pipeline and Ansible Tower.

### Prerequisites

- [ ] New Docker image built and pushed to Artifactory
- [ ] All CI pipeline stages passed (lint, test, scan, build)
- [ ] Deployment approval obtained (for QA and PROD environments)
- [ ] Access to the CI/CD platform and Ansible Tower
- [ ] Target environment is healthy and accessible

### Steps

1. _Verify the build artifact exists in Artifactory with the correct version tag_
2. _Trigger the deployment pipeline for the target environment_
3. _Monitor the Ansible Tower job execution_
4. _Wait for the ECS service to stabilize / Kubernetes rollout to complete_
5. _Verify the new version is running via the health endpoint_

```bash
# Example: Check deployed version
curl -s https://<environment-url>/health | jq .

# Example: Check ECS service status
aws ecs describe-services --cluster healthpulse-<env> --services hp-portal-<env>

# Example: Check Kubernetes rollout status
kubectl rollout status deployment/healthpulse-portal -n healthpulse-<env>
```

### Verification

- [ ] Health endpoint returns `{"status":"healthy"}`
- [ ] Application loads correctly in the browser
- [ ] No errors in application logs
- [ ] Datadog metrics show normal behavior
- [ ] ALB health checks are passing

### Escalation

| Level | Contact | When |
|-------|---------|------|
| L1 | _DevOps team on-call_ | _Deployment fails or health check does not pass_ |
| L2 | _DevOps Lead_ | _Rollback required or multiple environments affected_ |
| L3 | _Engineering Manager_ | _Production outage exceeding 30 minutes_ |

---

## Runbook 2: Rolling Back a Deployment

### Description

Roll back the HealthPulse Portal to a previous known-good version when a deployment introduces issues.

### Prerequisites

- [ ] Previous stable version identified (image tag / build number)
- [ ] Previous image still available in Artifactory
- [ ] Access to the CI/CD platform, Ansible Tower, or kubectl

### Steps

1. _Identify the last known-good version from deployment history_
2. _Trigger rollback via Ansible Tower or kubectl_
3. _Monitor the rollback progress_
4. _Verify the previous version is running_
5. _Investigate the root cause of the failed deployment_

```bash
# Ansible Tower rollback
# Trigger the deployment pipeline with the previous version tag

# Kubernetes rollback
kubectl rollout undo deployment/healthpulse-portal -n healthpulse-<env>

# Kubernetes rollback to specific revision
kubectl rollout undo deployment/healthpulse-portal -n healthpulse-<env> --to-revision=<N>

# ECS rollback — update service to use previous task definition
aws ecs update-service --cluster healthpulse-<env> --service hp-portal-<env> \
  --task-definition healthpulse-portal:<previous-revision>
```

### Verification

- [ ] Health endpoint returns `{"status":"healthy"}`
- [ ] Application is functioning correctly with the previous version
- [ ] No errors in application or infrastructure logs
- [ ] Datadog alerts have cleared

### Escalation

| Level | Contact | When |
|-------|---------|------|
| L1 | _DevOps team on-call_ | _Rollback initiated_ |
| L2 | _DevOps Lead_ | _Rollback fails or issue persists after rollback_ |
| L3 | _Engineering Manager_ | _Data corruption or customer impact detected_ |

---

## Runbook 3: Scaling the Application

### Description

Scale the HealthPulse Portal up or down to handle changes in traffic load.

### Prerequisites

- [ ] Monitoring data confirming the need to scale (CPU, memory, request latency)
- [ ] Access to AWS Console, CLI, or kubectl
- [ ] Understanding of current capacity and cost implications

### Steps

1. _Review current metrics in Datadog (CPU utilization, memory, request count)_
2. _Determine the target desired count or HPA settings_
3. _Apply the scaling change_
4. _Monitor the scaling event_
5. _Verify application performance has improved_

```bash
# ECS — Update desired count
aws ecs update-service --cluster healthpulse-<env> --service hp-portal-<env> \
  --desired-count <N>

# Kubernetes — Manual scale
kubectl scale deployment/healthpulse-portal -n healthpulse-<env> --replicas=<N>

# Kubernetes — Update HPA
kubectl patch hpa healthpulse-portal-hpa -n healthpulse-<env> \
  -p '{"spec":{"minReplicas":<N>,"maxReplicas":<M>}}'

# Terraform — Update variable and apply
# Edit environments/<env>.tfvars: desired_count = <N>
cd terraform && terraform apply -var-file=environments/<env>.tfvars
```

### Verification

- [ ] New task count matches desired count
- [ ] All tasks/pods are healthy and passing health checks
- [ ] ALB is routing traffic to new targets
- [ ] Latency and error rates have improved
- [ ] No out-of-memory or CPU throttling events

### Escalation

| Level | Contact | When |
|-------|---------|------|
| L1 | _DevOps team on-call_ | _Scaling event triggered_ |
| L2 | _DevOps Lead_ | _Scaling does not resolve performance issues_ |
| L3 | _Engineering Manager + Cloud Architect_ | _Cost approval needed for significant scale-up_ |

---

## Runbook 4: Responding to a Health Check Failure

### Description

Investigate and resolve health check failures detected by the ALB, ECS, Kubernetes liveness/readiness probes, or Datadog monitors.

### Prerequisites

- [ ] Alert received (Datadog, Slack, email, or ALB unhealthy target notification)
- [ ] Access to AWS Console, CloudWatch Logs, kubectl, and Datadog
- [ ] Understanding of the application health endpoint (`GET /health`)

### Steps

1. _Identify which environment and instance(s) are failing health checks_
2. _Check the health endpoint directly_
3. _Review application logs for errors_
4. _Check infrastructure metrics (CPU, memory, disk, network)_
5. _Determine root cause and take corrective action_
6. _If application is unrecoverable, trigger a rollback (see Runbook 2)_

```bash
# Check health endpoint directly
curl -v https://<environment-url>/health

# ECS — Check task status
aws ecs describe-tasks --cluster healthpulse-<env> \
  --tasks $(aws ecs list-tasks --cluster healthpulse-<env> --query 'taskArns' --output text)

# ECS — View recent logs
aws logs tail /ecs/healthpulse-<env> --since 30m

# Kubernetes — Check pod status
kubectl get pods -n healthpulse-<env>
kubectl describe pod <pod-name> -n healthpulse-<env>
kubectl logs <pod-name> -n healthpulse-<env> --tail=100

# ALB — Check target health
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

### Verification

- [ ] Health endpoint returns `{"status":"healthy"}` with HTTP 200
- [ ] ALB target health shows all targets as healthy
- [ ] Datadog alerts have cleared
- [ ] Application is responding to user requests normally
- [ ] Root cause documented in incident log

### Escalation

| Level | Contact | When |
|-------|---------|------|
| L1 | _DevOps team on-call_ | _Health check alert received_ |
| L2 | _DevOps Lead + Application Developer_ | _Root cause not identified within 15 minutes_ |
| L3 | _Engineering Manager_ | _Production outage affecting end users_ |

---

!!! info "Runbook Maintenance"
    Review and update these runbooks after every incident. Add new runbooks as new operational procedures are introduced. All changes should be committed to Git and reviewed via pull request.
