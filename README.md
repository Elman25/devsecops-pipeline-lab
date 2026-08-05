# DevSecOps Infrastructure Pipeline Lab

Automated Security & Compliance CI/CD Pipeline for Infrastructure as Code (IaC) and Configuration Management.


## Architecture & Security Scanning Stack:

**Secret Detection**: Gitleaks for Git Commits & History
**IaC Security**: Checkov for Terraform (`.tf`)
**Linting & Best Practices**: Ansible-Lint for Ansible Playbooks 
**SCA / Vulnerability Scan**: Trivy for Repository Filesystem


## Local Development & Pipeline Execution

### Prerequisites
* Docker / Container Runtime
* Terraform `>= 1.0.0`
* Checkov
* Ansible & Ansible-Lint
* Pre-commit & Gitleaks

### Local Verification

bash

1. Run secret scanning
pre-commit run --all-files

2. Run IaC security checks
cd terraform && checkov -d .

3. Validate Ansible playbooks
cd ../ansible && ansible-lint playbook.yml

### Continuous Integration (GitHub Actions)
The workflow located at `.github/workflows/devsecops.yml` runs automatically on `push` and `pull_request` targeting the `main` branch. Any check returning a non-zero exit code blocks the deployment


## Note: Project is still under development. Some features might not work
