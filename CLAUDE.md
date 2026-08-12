# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a DevOps playground project focused on cloud code and infrastructure automation. It consists of a lightweight Python HTTP server with health check endpoints, infrastructure-as-code (Terraform for AWS), Kubernetes manifests, and a GitHub Actions CI/CD pipeline.

## Development Workflow

### Running the Application

```bash
python app/main.py
```

The server starts on `localhost:8080` and provides a `/health` endpoint that returns `{"status": "ok"}`.

### Running Tests

Run all tests:
```bash
python -m unittest discover app/tests
```

Run a specific test file:
```bash
python -m unittest app.tests.test_health
```

### Linting & Code Quality

No linting tools are currently configured. Python code follows standard conventions.

## Project Architecture

### Application Layer (`/app`)

**`main.py`** — Simple HTTP server using Python's built-in `http.server` library.
- Single endpoint: `GET /health` returns JSON status
- Listens on `0.0.0.0:8080`
- Minimal dependencies (no external frameworks)

**`tests/`** — Unit tests using Python's `unittest` framework.
- Test discovery runs on all files in this directory
- Currently basic smoke tests; expand as needed

### Infrastructure Layer (`/infra`)

**Terraform** (`terraform/`) — AWS infrastructure provisioning.
- `main.tf` — Defines an EC2 t3.micro instance with the app deployed
- `variables.tf` — Configurable region and AMI ID
- Provider: AWS, default region: `us-east-1`
- To use: initialize with `terraform init`, plan with `terraform plan -var "ami_id=..."`, apply with `terraform apply`

**Kubernetes** (`kubernetes/`) — Container orchestration configuration.
- `deployment.yaml` — 2-replica deployment pulling `devops-playground:latest` image
- Exposes container port 8080
- To deploy: `kubectl apply -f infra/kubernetes/deployment.yaml`

### CI/CD Pipeline

**GitHub Actions** (`.github/workflows/ci.yaml`)
- Triggers on push and pull requests to any branch
- Job: `test` — runs on `ubuntu-latest`
- Steps: checkout code, then execute `python -m unittest discover app/tests`
- Tests must pass before merging

## Key Design Notes

- **Stateless app**: The HTTP server is simple and stateless; suitable for horizontal scaling in Kubernetes
- **Language**: Code comments and variable names use Portuguese; maintain this convention for consistency
- **Minimal dependencies**: App uses only Python standard library; keep it lightweight
- **Configuration**: Terraform and Kubernetes both reference an image tag `devops-playground:latest` — ensure Docker builds produce this tag before infrastructure changes

## Next Steps for Expansion

- Add a Dockerfile to containerize the Python app
- Expand test coverage and add integration tests
- Add Terraform outputs for EC2 IP address
- Configure Kubernetes service to expose the deployment
- Add environment-based configuration (dev/staging/prod)
