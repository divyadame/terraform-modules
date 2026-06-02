
# ==============================================================================
# 3. MODULE OUTPUTS
# ==============================================================================

# CRUCIAL ADDITION: The bastion host needs this to build its IAM Policy!
output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "eks_cluser_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "The security group ID associated with the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_node_group_arn" {
  description = "The ARN of the EKS node group."
  value       = module.eks.eks_managed_node_groups["eks_nodes"].node_group_arn
}

output "eks_node_security_group_id" {
  description = "The security group ID associated with the EKS worker nodes."
  value       = module.eks.node_security_group_id
}

