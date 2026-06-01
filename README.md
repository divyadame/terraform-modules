________________________________________
🏗️ Multi-Environment AWS Infrastructure with Terraform
This repository orchestrates a production-grade, modular cloud infrastructure on AWS. It uses a Write-Once, Deploy-Many architecture to provision isolated environments (Development, Staging, Production) using a single, unified codebase.
________________________________________
🧭 System Blueprint & Architecture
The deployment architecture is split into two distinct tiers: Global Infrastructure Elements and Environment Execution Workspaces.
```text
.
├── environments/
│   ├── dev/
│   │   ├── main.tf          # 🚀 Execution Root (Petclinic Dev workspace)
│   │   ├── terraform.tfvars # 🎛️ Environment configuration overrides
│   │   └── outputs.tf
│   └── prod/
│       └── main.tf          # 🔒 Execution Root (Petclinic Prod workspace)
└── modules/
    ├── vpc/                 # 🌐 Base Networking Fabric
    ├── ec2/                 # 💻 Compute & Bastion Admin Layer
    └── eks/                 # ☸️ Container Control Fabric (EKS Control Plane)
    |__ ecr/
```

_________________________
🛠️ The Module Framework
Every core cloud infrastructure component is packaged into a reusable module layout inside the /modules folder:
•	🌐 Network Fabric (/vpc): Generates public and private subnets across multi-AZ architectures, establishing absolute network isolation.
•	💻 Compute Control Box (/ec2): Deploys automated administrative jumpboxes (Bastion Hosts) to safely interact with private internal resources.
•	☸️ Container Orchestrator (/eks): Leverages the official community AWS EKS framework to spin up auto-scaling managed node groups running secure, standardized container runtimes.
•	📦 Container Registry (Inline ECR): Deploys a dedicated aws_ecr_repository configured with auto-scanning on push (disabled for now) and native KMS encryption layer hooks.
________________________________________
🌍 Designing Apps Across Different Environments
Our workflow solves the traditional "it works on my machine" problem by enforcing exact architectural parity across all stages while adjusting sizing parameters dynamically.
1. Unified Naming & Tagging Standards
Every resource is explicitly dynamically prefixed using a combination of the global environment and application variables:
hcl
name = "${var.environment}-${var.application}-eks-cluster"
Use code with caution.
•	Development Instance: dev-petclinic-eks-cluster
•	Production Instance: prod-petclinic-eks-cluster
This prevents naming collisions within the same AWS account and ensures clear billing tracking.
2. Variable-Driven Environment Sizing
Instead of altering code blocks to scale up for Production, you simply pass different variables into the identical module framework. This ensures that a bug discovered in Staging behaves exactly the same way in Production.
Configuration Target	Development Settings (dev)	Production Settings (prod)
EKS Public Endpoint Access	true (Easy Developer Debugging)	false (Private Network Only)
Compute Instance Type	t3.micro (Low-cost testing)	m6i.large (Production Performance)
Worker Node Group Scaling	Min: 1 | Desired: 2 | Max: 3	Min: 3 | Desired: 5 | Max: 10
Image Mutability (ECR)	MUTABLE (Rapid build overwrites)	IMMUTABLE (Production Tag Locking)
________________________________________
🚀 Execution & Deployment Guide
To deploy any given environment layer, navigate to its respective folder under environments/ and execute the following standard lifecycle commands:
1. Initialize and Update Cache
bash
terraform init -upgrade
Use code with caution.
(This purges local directory maps, maps the modular dependencies cleanly, and downloads public providers).
2. Validate and Plan
bash
terraform plan
Use code with caution.
(Inspect the target execution plan to confirm exactly what changes will take place in the target cloud zone).
3. Provision Infrastructure
bash
terraform apply
Use code with caution.
________________________________________
🛡️ Reliability & Security Fail-Safes
•	Zero-Downtime Infrastructure Refactoring: Critical edge resources (such as ECR registries and network routing links) use create_before_destroy = true lifecycles to assure that replacements don't drop in-flight platform connectivity.
•	Container Security Guardrails: Every ECR registry automatically scans images for security vulnerabilities on push using automated engine triggers.

