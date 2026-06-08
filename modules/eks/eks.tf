# ==============================================================================
# 1. THE EKS CLUSTER DEFINITION (Official Community Module)
# ==============================================================================
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = "${var.environment}-${var.application}-eks-cluster"
  cluster_version = "1.31"
  tags = merge(var.tags, {
    Environment = var.environment
  })
  
  cluster_endpoint_public_access = var.public_access
  
  # Clutser addons Must
  # VPC-CNI addon gives your pods IP addresses from your VPC
  # core-dns addon handles internal clutser lookups
  # eks-pod-identity-agent bridges kubernetes applications with 
  # ....AWS IAM roles to call AWS services outside from cluster
  # kube-proxy dictates/create rules in worker node's kernal basic internal pod-to-pod routing.
  # aws-ebs-csi-driver provides storage for stateful apps

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
  }
  
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
  
  # FIXED: Explicitly tell EKS to process your access_entries API configuration
  authentication_mode = "API_AND_CONFIG_MAP"

  # FIXED: Moved inside the module configuration block
  # Cluster access entry to add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = false

  # FIXED: Moved inside the module configuration block
  # Using access entries which sets the user to grant cluster admin access
  access_entries = {
    example = {
      principal_arn = "arn:aws:iam::200774433341:user/Admin"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  
  #This is create worker nodes and eks module configures the EKS cluster IAM role
  # and The Cluster Security Group
    eks_managed_node_groups = {
    eks_nodes = {
      ami_type       = var.node_group_ami_type
      instance_types = [var.node_group_instance_type] 
      
      min_size       = var.node_group_min_capacity
      max_size       = var.node_group_max_capacity
      desired_size   = var.node_group_desired_capacity
      capacity_type  = var.node_group_capacity_type
      
      # ==============================================================================
      # ADDITIONAL POLICIES BLOCK
      # ==============================================================================
      # Required by worker nodes to give them the standard storage permissions.
      iam_role_additional_policies = {
        # 1. Required so your 'aws-ebs-csi-driver' addon can create disks
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
       
        # 2. Safe-guard: Required if var.node_group_ami_type evaluates to "AL2_x86_64"
        # Not required if you are using AL2023_x86_64 
        AmazonEKSPodIdentityWorkerPolicy = "arn:aws:iam::aws:policy/AmazonEKSPodIdentityWorkerPolicy"
      }

      tags = merge(var.tags, {
        Name = "${var.environment}-${var.application}-eks-node"
      })
    }
  }
}