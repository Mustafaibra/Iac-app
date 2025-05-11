# Infrastructure as Code (IaC) Application

## Overview

This repository contains Terraform configurations for deploying and managing cloud infrastructure across multiple environments. The solution implements CI/CD best practices with automated workflows for development and production environments.

## Environment Management

The repository supports isolated deployment environments through Terraform workspaces:

| Environment    | Workspace  | Trigger Condition              |
|----------------|------------|--------------------------------|
| Production     | `prod`     | Merges to `main` branch        |
| Development    | `dev`      | All other branches and PRs     |

This separation enables safe testing of infrastructure changes before promoting to production.

**Relevant Implementation**:  
See [`/.github/workflows/deployment.yaml`](/.github/workflows/deployment.yaml) (lines 75-86)

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- AWS Access Key and Secret Key
- Terraform installed (version X.X.X or higher)
- GitHub Actions enabled for the repository

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Mustafaibra/Iac-app.git
   cd Iac-app

export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
Development workflow:

Create a feature branch

Make infrastructure changes

Create a pull request to trigger Dev environment deployment

Review changes in Dev environment

Production deployment:

Merge approved changes to main branch

CI/CD pipeline will automatically deploy to Production

Documentation
For complete documentation, please visit:
📚 [DeepWiki Documentation](https://deepwiki.com/Mustafaibra/Iac-app)

Key Documentation Sections:
CI/CD Pipeline Configuration

AWS Infrastructure Architecture

Environment Management Guide

