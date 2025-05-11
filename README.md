This document provides a comprehensive overview of the Continuous Integration and Continuous Deployment (CI/CD) pipeline implemented in the Iac-app repository. The pipeline automates the process of validating, planning, and deploying infrastructure as code to AWS environments. For specific details on the actual AWS infrastructure being deployed, see AWS Infrastructure Architecture.

Pipeline Overview
The CI/CD pipeline is implemented using GitHub Actions and is designed to provide automated deployment of infrastructure with quality gate checks. The pipeline supports multiple deployment scenarios and environment configurations through a combination of triggers and parameters.

Environments

Terraform Operations

GitHub Actions Workflow

Trigger Events

Output status

Output status

Branch = main

Branch ≠ main

Status: success/failure

Pull Request
(opened/reopened)

Push to main

Manual Workflow
Dispatch

Deployment Job

Quality Gate Job

terraform init

terraform validate

terraform fmt -check

terraform apply

terraform destroy

Dev Workspace

Prod Workspace

GitHub Status API

Sources: 
.github/workflows/deployment.yaml
3-22
 
.github/workflows/deployment.yaml
67-74
 
.github/workflows/deployment.yaml
75-93

Trigger Mechanisms
The pipeline can be triggered in three different ways:

Manual Workflow Dispatch: Users can manually trigger the workflow with specific deployment options.
Push to main Branch: Automatically triggered when code is pushed to the main branch.
Pull Request Events: Triggered when a pull request is opened or reopened.
Manual Workflow Dispatch Options
When triggering the workflow manually, users can choose from the following options:

Option	Description
Apply	Only applies the infrastructure changes
Destroy	Only destroys the infrastructure
Apply and Destroy	Applies the changes and then destroys them (useful for testing)
The default selection is "Apply".

Sources: 
.github/workflows/deployment.yaml
3-14

Deployment Workflow
The main deployment job performs a series of operations to validate and deploy the infrastructure:

"AWS Environment"
"GitHub Actions Cache"
"GitHub Actions Runner"
"GitHub"
"AWS Environment"
"GitHub Actions Cache"
"GitHub Actions Runner"
"GitHub"
alt
[Cache hit]
[Cache miss]
alt
[Branch == main]
[Other branch]
alt
[Apply or Apply and Destroy selected]
alt
[Destroy or Apply and Destroy selected]
Trigger workflow
Checkout code
Setup Terraform
Check for Terraform modules cache
Provide cached .terraform
terraform init
Save .terraform to cache
terraform fmt -check
terraform validate
Select or create "Prod" workspace
Select or create "Dev" workspace
terraform apply
terraform destroy
Report job status
Sources: 
.github/workflows/deployment.yaml
23-93

Key Steps in the Workflow
Environment Setup:

Configures AWS credentials from GitHub secrets
Sets up Terraform on the runner
Uses caching to speed up subsequent runs by storing the .terraform directory
Terraform Initialization:

Initializes Terraform with remote backend configuration
Only runs if cache is not available
Validation and Formatting:

Runs terraform fmt -check to ensure code is properly formatted
Runs terraform validate to check for configuration errors
Captures the exit code to determine if quality gates passed
Workspace Selection:

Selects the "Prod" workspace for deployments from the main branch
Selects the "Dev" workspace for all other deployments
Creates the workspace if it doesn't exist
Infrastructure Deployment:

Based on the selected action, either applies or destroys the infrastructure
Uses auto-approve to run non-interactively
Passes AWS credentials as variables to Terraform
Sources: 
.github/workflows/deployment.yaml
34-93

Quality Gate System
The quality gate system ensures that infrastructure code meets standards before deployment. This is particularly important for pull requests that target the main branch.

Quality Gate Job

Deployment Job

Yes

No

Run terraform fmt & validate
Capture exit code

Output test results

Check quality gate result

Create commit status

Result == 0?

Mark as success
Allow deployment

Mark as failure
Fail workflow

Report to GitHub Status API

The quality gate job:

Only runs for branches other than main
Takes the result of the validation and formatting checks
Creates a commit status to indicate success or failure
Fails the workflow if quality gate checks fail
Sources: 
.github/workflows/deployment.yaml
95-103
 
.github/workflows/script-reuse.yaml
1-33

Quality Gate Implementation
The quality gate is implemented as a reusable workflow that:

Receives an input parameter with the test result
Interprets the exit code (0 = success)
Reports the status to the GitHub Status API
Throws an error if the quality gate failed, preventing further workflow execution
This ensures that only properly formatted and validated Terraform code can be merged into the main branch.

Sources: 
.github/workflows/script-reuse.yaml
10-33

Dependency Management
The repository uses GitHub's Dependabot to automatically keep GitHub Actions dependencies up to date:

Weekly scan

Find outdated
GitHub Actions

Up to 10 PRs

Trigger

Dependabot Service

Repository

Create update PRs

Review & Merge

CI/CD Pipeline

Dependabot is configured to:

Check for GitHub Actions updates weekly
Open up to 10 pull requests at a time
Automatically request reviews for these updates
This ensures that the CI/CD pipeline itself stays updated with the latest features and security patches.

Sources: 
.github/dependabot.yaml
1-7

Environment Management
The pipeline uses Terraform workspaces to manage different environments:

Push to main

PR or other branch

Trigger Event

Main Branch Detected

Development Branch Detected

terraform workspace select
-or-create Prod

terraform workspace select
-or-create Dev

Production Infrastructure
(Prod workspace state)

Development Infrastructure
(Dev workspace state)

This approach allows:

Isolation between environments (development vs. production)
Same code base for all environments
Different state files for each environment
Ability to test changes in development before applying to production
Sources: 
.github/workflows/deployment.yaml
75-86

Security Considerations
The pipeline implements several security features:

Secrets Management:

AWS credentials are stored as GitHub secrets
Credentials are passed to Terraform as variables
Credentials are not logged or exposed in the workflow
Branch Protection:

Quality gate ensures code quality before merging to main
Only code that passes validation can be merged into production
Limited Permissions:

The quality gate job uses minimal permissions (only statuses and contents)
Follows the principle of least privilege
Sources: 
.github/workflows/deployment.yaml
28-30
 
.github/workflows/deployment.yaml
96-99

Conclusion
The CI/CD pipeline in this repository provides a robust system for deploying and managing infrastructure as code on AWS. It enforces quality standards, supports multiple environments, and provides flexibility for different deployment scenarios.

For more detailed information about specific aspects of the pipeline:

For the deployment workflow steps, see Deployment Workflow
For more details on the quality gate system, see Quality Gate System
For information about dependency management, see Dependency Management
