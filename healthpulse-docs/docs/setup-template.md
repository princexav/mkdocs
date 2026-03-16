# Tool Setup Template

_Copy this page for each tool you install. Rename it `setup-<tool-name>.md` and add it to the navigation in `mkdocs.yml`._

---

## Server Info

| Item | Value |
|------|-------|
| **Tool Name** | _e.g., Jenkins, SonarQube, Artifactory, Ansible Tower_ |
| **Instance Type** | _e.g., t2.xlarge_ |
| **OS** | _e.g., Ubuntu 22.04 LTS_ |
| **Storage** | _e.g., 20 GB_ |
| **Ports** | _e.g., 8080 (UI), 50000 (agents)_ |
| **IP / URL** | _`<ip-or-url>`_ |
| **Provisioned By** | _Terraform / Manual_ |

---

## Installation Commands

_Paste every command you ran — this must be reproducible._

```bash
# Step 1: System preparation
# <your commands here>

# Step 2: Install the tool
# <your commands here>

# Step 3: Start the service
# <your commands here>

# Step 4: Verify installation
# <your commands here>
```

---

## Initial Configuration

_What you did after the tool was running (first login, admin setup, etc.)._

1. _Navigate to `http://<ip>:<port>`_
2. _Default credentials: `admin / <default-password>`_
3. _Changed password to: stored in Ansible Vault_
4. _Completed setup wizard_
5. _Additional config..._

---

## Integrations

_How this tool connects to other tools in the pipeline._

| Integrated With | Method | Status |
|----------------|--------|--------|
| _Jenkins_ | _Plugin / API / Webhook_ | [ ] Working |
| _SonarQube_ | _Token / API_ | [ ] Working |
| _Artifactory_ | _Service account_ | [ ] Working |
| _Datadog_ | _Agent / API_ | [ ] Working |

---

## Users & Credentials

| User / Credential | Type | Purpose | Created? |
|-------------------|------|---------|----------|
| _admin_ | _Password_ | _Admin access_ | [ ] |
| _jenkins-svc_ | _API token_ | _Pipeline integration_ | [ ] |

!!! warning "Security"
    Never commit actual passwords or tokens here. Reference Ansible Vault or Secrets Manager.

---

## Verification Checklist

- [ ] Tool UI accessible at expected URL
- [ ] Admin password changed from default
- [ ] Integration with CI/CD pipeline tested
- [ ] Data persists across restarts
- [ ] Datadog agent monitoring this server
- [ ] Firewall / security group rules configured

---

## Troubleshooting

_Document any issues you hit during setup and how you fixed them._

| Problem | Root Cause | Solution |
|---------|-----------|----------|
| _Describe the issue_ | _What caused it_ | _How you fixed it_ |
| _..._ | _..._ | _..._ |

---

## Screenshots

_Paste screenshots here as evidence of your setup._

<!-- ![Dashboard](../img/tool-dashboard.png) -->

---

!!! info "Template Instructions"
    1. Copy this file: `cp setup-template.md setup-<tool-name>.md`
    2. Fill in every section with your actual commands and values
    3. Add to `mkdocs.yml` nav under **Setup Guides**
    4. Commit and push — docs site auto-rebuilds
