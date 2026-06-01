output "bastion_public_ip" {
  description = "The public IP address of the bastion host to SSH into."
  value       = module.ec2.instance_public_ip
}

output "bastion_security_group_id" {
  description = "The security group ID assigned to the bastion host."
  value       = module.ec2.instance_security_group_id
}

output "eks_cluster_name" {
  description = "The exact name of your deployed EKS cluster."
  value       = module.eks.eks_cluser_name
}

output "eks_cluster_endpoint" {
  description = "The private network endpoint URL for the Kubernetes API."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "The main control plane security group protecting the EKS cluster."
  value       = module.eks.eks_cluster_security_group_id
}

output "ecr_url" {
  value = module.ecr.repo_url
}

output "ssh_connection_command" {
  description = "Command to log into the bastion host."
  value       = "ssh -i ~/.ssh/bastion-key ec2-user@${module.ec2.instance_public_ip}"
}

output "kubeconfig_update_command" {
  description = "Command to run inside the bastion host to connect kubectl."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.eks_cluser_name}"
}

