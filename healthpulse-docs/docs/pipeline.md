# CI/CD Pipeline

This page documents the HealthPulse CI/CD pipeline architecture, stages, and configuration.

---

## Pipeline Overview

The HealthPulse project uses two main pipelines:

1. **HealthPulse_Build** — Continuous Integration (build, test, scan, package)
2. **HealthPulse_Deploy** — Continuous Deployment (deploy to target environment)

---

## CI Pipeline: HealthPulse_Build

### Pipeline Stages

```
+----------+    +---------+    +------+    +------------+    +-----------+
| Checkout |--->| Install |--->| Lint |--->| Unit Tests |--->| SonarQube |
+----------+    +---------+    +------+    +------------+    +-----------+
                                                                   |
                                                                   v
+--------------+    +-------------+    +-------+    +-----------+
| Artifactory  |<---| Docker Push |<---| Build |<---| Snyk Scan |
|    Upload    |    |             |    |       |    |           |
+--------------+    +-------------+    +-------+    +-----------+
                                                         |
                                                         v
                                                   +-----------+
                                                   |  Notify   |
                                                   |  (Slack)  |
                                                   +-----------+
```

### Stage Descriptions

| Stage | Tool | Command | Description |
|-------|------|---------|-------------|
| **Checkout** | Git | `git checkout` | Clone repository and checkout the target branch |
| **Install** | npm | `npm ci` | Install dependencies using clean install |
| **Lint** | ESLint | `npm run lint` | Run static code analysis for code style and errors |
| **Unit Tests** | Vitest | `npm run test:coverage` | Run unit tests, produce coverage report and JUnit XML |
| **SonarQube** | SonarScanner | `sonar-scanner` | Static analysis, quality gate check, coverage upload |
| **Snyk Scan** | Snyk CLI | `snyk test` | Dependency vulnerability scanning (threshold: HIGH) |
| **Build** | Vite | `npm run build` | Production build, outputs to `dist/` |
| **Docker Push** | Docker | `docker build && docker push` | Multi-stage Docker build, push to Artifactory |
| **Artifactory Upload** | JFrog CLI | `jfrog rt upload` | Upload versioned build artifacts |
| **Notify** | Slack / Email | Webhook | Send build result notification |

### Trigger Configuration

| Trigger | Detail |
|---------|--------|
| **Automatic** | Webhook on push to any branch |
| **Version Tag** | `<build-number>-<git-short-hash>` (e.g., `42-a1b2c3d`) |

### Quality Gates

| Gate | Tool | Criteria |
|------|------|----------|
| Code Quality | SonarQube | Quality gate must pass (no new critical/blocker issues) |
| Security | Snyk | No HIGH or CRITICAL vulnerabilities |
| Test Coverage | Vitest + SonarQube | _Minimum coverage threshold (configure per team)_ |

### Notifications

| Event | Channel | Recipients |
|-------|---------|------------|
| Build Success | Slack `#healthpulse-builds` | Team |
| Build Failure | Slack `#healthpulse-builds` + Email | Team + Lead |

---

## CD Pipeline: HealthPulse_Deploy

### Deployment Pipelines

| Pipeline | Target | Trigger | Gate |
|----------|--------|---------|------|
| `HealthPulse_Dev_Deploy` | DEV | Automatic on `develop` branch | None |
| `HealthPulse_UAT_Deploy` | UAT | Automatic on `release/*` branches | None |
| `HealthPulse_QA_Deploy` | QA | Manual trigger | Approval required |
| `HealthPulse_Prod_Deploy` | PROD | Manual trigger from `main` | Manager approval required |

### Deployment Flow

```
develop branch push
       |
       v
  [DEV Deploy] ---> Ansible Tower ---> ECS/EKS DEV
       |
release/* branch push
       |
       v
  [UAT Deploy] ---> Ansible Tower ---> ECS/EKS UAT
       |
  Manual trigger + approval
       |
       v
  [QA Deploy] ----> Ansible Tower ---> ECS/EKS QA
       |
  Manual trigger + manager approval
       |
       v
  [PROD Deploy] --> Ansible Tower ---> ECS/EKS PROD
```

### Deployment Steps

1. Pull Docker image from Artifactory with specified version tag
2. Trigger Ansible Tower job template for target environment
3. Ansible playbook updates ECS task definition / Kubernetes deployment
4. Wait for service to stabilize (health check passes)
5. Send deployment notification to Slack

---

## Tool Configuration Notes

### Jenkins

```groovy
// Jenkinsfile location: pipelines/Jenkinsfile
// Key plugins required:
// - Pipeline, Git, Docker Pipeline
// - SonarQube Scanner, Snyk Security
// - Slack Notification, Email Extension
// - Artifactory, Ansible
```

_Configure Jenkins credentials for: Git SSH key, Artifactory, SonarQube token, Snyk token, Slack webhook, AWS credentials, Ansible Tower._

### GitLab CI

```yaml
# .gitlab-ci.yml location: pipelines/.gitlab-ci.yml
# Key configuration:
# - Stages: lint, test, scan, build, deploy
# - Variables: stored in GitLab CI/CD settings
# - Runners: Docker executor
```

_Configure GitLab CI/CD variables for: Artifactory credentials, SonarQube token, Snyk token, AWS credentials._

### Azure DevOps

```yaml
# azure-pipelines.yml location: pipelines/azure-pipelines.yml
# Key configuration:
# - Stages with jobs and steps
# - Service connections for AWS, Artifactory
# - Variable groups for secrets
```

_Configure Azure DevOps service connections and variable groups for all integrations._

---

## Docker Image Versioning

| Component | Format | Example |
|-----------|--------|---------|
| Registry | Artifactory URL | `artifactory.example.com/healthpulse` |
| Image Name | `healthpulse-portal` | `healthpulse-portal` |
| Tag | `<build>-<hash>` | `42-a1b2c3d` |
| Full Image | `<registry>/<image>:<tag>` | `artifactory.example.com/healthpulse/healthpulse-portal:42-a1b2c3d` |

---

## SonarQube Configuration

```properties
# sonar-project.properties (in project root)
sonar.projectKey=healthpulse-portal
sonar.projectName=HealthPulse Portal
sonar.sources=src
sonar.tests=src/test
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.testExecutionReportPaths=test-results/junit.xml
```

---

!!! note "Pipeline Files"
    Reference pipeline configuration files are provided in the `pipelines/` directory. Adapt these templates for your chosen CI/CD platform.
