eks.tf
What it does? what resources it creates?

This module condenses over 50 raw AWS resources into a single configuration block. Writing this from scratch without the module would require over 1,000 lines of complex Terraform code.
Here is exactly what this module provisions and configures behind the scenes, broken down by category:
1. EKS Control Plane (The Master Nodes)
•	Provisions the highly available Kubernetes control plane managed by AWS.
•	Configures network endpoints based on your cluster_endpoint_public_access variable.
•	Generates the EKS cluster IAM service role (AmazonEKSClusterPolicy) so the control plane can interact with other AWS systems.
2. Networking & Firewalls (Security Groups)
•	Creates a Cluster Security Group that establishes a secure firewall around the control plane.
•	Creates a Node Security Group that handles standard network traffic rules for your compute nodes.
•	Configures secure cross-communication, opening up Port 443 (HTTPS) and Port 10250 (Kubelet API) between the control plane and your worker nodes automatically.
3. Cluster Access Management (RBAC Bridge)
•	Activates the native EKS Access Entries API via authentication_mode.
•	Explicitly links the AWS IAM user arn:aws:iam::200774433341:user/Admin to the cluster.
•	Binds that user to the AWS-managed cluster admin policy, granting them root system:masters level authorization.
4. Core Addons Deployment
Directly installs and initializes five essential cluster-level engines:
•	vpc-cni: Provisions network interfaces to hand out direct AWS VPC IP addresses to your pods.
•	coredns: Sets up service discovery and domain lookup inside the cluster.
•	kube-proxy: Configures kernel-level network routing paths on your nodes.
•	eks-pod-identity-agent: Prepares the cluster to pass IAM execution tokens to pods.
•	aws-ebs-csi-driver: Deploys the engine required to hook pods up to persistent AWS storage disks.
5. Managed Worker Nodes (Compute Capacity)
•	Creates an EC2 Launch Template containing OS settings, network structures, and launch flags.
•	Creates an EC2 Auto Scaling Group governed by your min, max, and desired capacity variables.
•	Generates a Node IAM Instance Profile containing the core AWS policies (AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy).
•	Injects your two custom policies (AmazonEBSCSIDriverPolicy and AmazonEKSPodIdentityWorkerPolicy) into that node profile.
•	Executes a bootstrap script on the EC2 instances at boot time, forcing them to automatically locate your control plane and securely register as healthy worker nodes.

EKS contole Plane to EKS Worker node communication: How?

The terraform-aws-modules/eks/aws module handles all cross-service communication automatically [The EKS Cluster Definition (Official Community Module)].

How the Module Sets Up Control Plane to Node CommunicationBehind the scenes, the module configures two critical AWS security components automatically:

The EKS Cluster IAM Role: Terraform automatically creates a specialized IAM role for your control plane and attaches the AWS-managed policy AmazonEKSClusterPolicy. This policy grants the control plane permission to discover network interfaces and manage traffic flow to your instances.The Cluster Security Group: The module configures automated firewall rules (Security Group ingress and egress rules) between the control plane and your eks_nodes group. This opens up network ports 443 (HTTPS) and 10250 (Kubelet API), allowing the control plane to securely schedule pods, stream logs, and check node health.

Everything required for the control plane to manage the worker nodes is completely baked into your current configuration [The EKS Cluster Definition (Official Community Module)].

LB_controller_addon - AWS Load Balancer Controller ? what it does ? 

This code automatically installs and configures the AWS Load Balancer Controller inside your EKS cluster using modern security best practices.
It handles two primary jobs: creating the AWS permissions and deploying the controller software.
________________________________________
1. The Permissions Part (module "lb_controller_pod_identity")
This block creates a bridge between AWS IAM and Kubernetes using EKS Pod Identity.
•	Creates an IAM Role: It provisions an AWS IAM Role specifically for the Load Balancer Controller.
•	Attaches Policies: Setting attach_aws_lb_controller_policy = true automatically gives this role full permissions to create, update, and delete AWS Application Load Balancers (ALBs) and Network Load Balancers (NLBs).
•	Maps to Kubernetes: The associations block locks this IAM role directly to a specific Kubernetes service account named aws-load-balancer-controller inside the kube-system namespace. Only pods using this service account can touch your AWS networking hardware.
2. The Software Part (resource "helm_release" "aws_lb_controller")
This block downloads and installs the actual controller agent application into your cluster control plane.
•	Downloads Software: It pulls the official controller package from the verified AWS Helm repository (https://aws.github.io/eks-charts). [1]
•	Links to Your Cluster: It tells the controller software exactly which EKS cluster it is managing via module.eks.cluster_name.
•	Activates Permissions: It creates the matching aws-load-balancer-controller service account, allowing the app to inherit the IAM permissions generated in the step above.
•	Ensures Ordering: The depends_on rule forces Terraform to wait until your core EKS cluster and IAM role are 100% created before trying to install the software.
What is the end result in production?
Once applied, you can deploy standard Kubernetes Ingress manifests. The controller will instantly detect them, talk to AWS APIs behind the scenes, and automatically spin up real AWS Application Load Balancers (ALBs) to route public internet traffic directly into your application pods.

external secrets operator - secrets_operator_addon - what it does?
This configuration automatically deploys and securely permissions the External Secrets Operator (ESO) engine into your Amazon EKS cluster.
It bridges your AWS cloud layer and your Kubernetes runtime so that database passwords can safely synchronize into the cluster without manual rotation or hardcoded credentials.
________________________________________
Structural Breakdown
1. The AWS Permission Vault Guard (aws_iam_policy.app_db_secrets)
This block constructs a restrictive AWS IAM security policy.
•	Granular Actions: It restricts permissions strictly to reading data (GetSecretValue and DescribeSecret). It blocks all creation, deletion, or modification privileges.
•	Production Boundary: It applies a strict naming filter (secret:${var.environment}-${var.application}-db-*). The operator is securely locked out of all other corporate secrets residing within the same AWS account.
2. The Identity Bridge (module.app_secrets_pod_identity)
This utilizes the modern EKS Pod Identity API framework.
•	No Access Keys: It maps your AWS IAM policies directly to your Kubernetes compute tier without handling configuration file keys or credential files.
•	Target Mapping: It explicitly binds the database permissions to a service account called external-secrets running specifically inside the administrative kube-system namespace.
3. The Live Engine Installation (helm_release.external_secrets)
This pulls and deploys the operational controller software directly onto your cluster nodes.
•	Verified Origin: It streams the code safely from the official endpoint (https://charts.external-secrets.io).
•	Schema Activation: Setting installCRDs = true injects the global object definitions into your cluster database (such as the SecretStore and ExternalSecret types).
•	Identity Inheritance: Forcing the chart to use the name external-secrets ensures the deployed software pod inherits the Pod Identity permission slip generated in the prior steps.
________________________________________
What Happens When You Run terraform apply?
┌──────────────────────────┐      1. Pod Identity      ┌──────────────────────────────┐
│  AWS Secrets Manager     │ ────────────────────────> │ External Secrets Operator    │
│  (Holds Database Clear)  │                           │ (Running in kube-system Namespace)
└──────────────────────────┘                           └──────────────────────────────┘
                                                                      │
                                                                      │ 2. Dynamically
                                                                      │    Generates
                                                                      ▼
                                                       ┌──────────────────────────────┐
                                                       │  Standard Native K8s Secret  │
                                                       │  (Read by App Env Variables) │
                                                       └──────────────────────────────┘
1.	The underlying infrastructure, storage definitions, and IAM roles are completely generated.
2.	The Helm release bootstraps the central controller pod inside your kube-system namespace.
3.	The pod continuously looks out for custom resources, safely logs into AWS Secrets Manager, and pulls down your strings to inject them securely into local cluster memory.

