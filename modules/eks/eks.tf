# ==============================================================================
# 1. THE EKS CLUSTER DEFINITION (Official Community Module)
# ==============================================================================
# ==============================================================================
# 1. THE EKS CLUSTER DEFINITION (Official Community Module)
# ==============================================================================
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"
    
    cluster_name = "${var.environment}-${var.application}-eks-cluster"
    tags = merge(var.tags, {
        Environment = var.environment
    })
    
    cluster_endpoint_public_access = var.public_access
    
    vpc_id     = var.vpc_id
    subnet_ids = var.private_subnet_ids
    
    eks_managed_node_groups = {
        eks_nodes = {
            # FIXED: Version 20.x expects these exact parameter names
            min_size     = var.node_group_min_capacity
            max_size     = var.node_group_max_capacity
            desired_size = var.node_group_desired_capacity

            instance_types = [var.node_group_instance_type]
            capacity_type  = var.node_group_capacity_type
            ami_type       = var.node_group_ami_type
            
            tags = merge(var.tags, {
                Name = "${var.environment}-${var.application}-eks-node"
            })
        }
    }
}
