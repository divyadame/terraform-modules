
# ==============================================================================
# 2. INGRESS RULE: ALLOW BASTION TO CONTROL EKS
# ==============================================================================
resource "aws_security_group_rule" "bastion_to_eks" {
    type        = "ingress"
    description = "Allow inbound HTTPS traffic from bastion host to EKS control plane"

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    # Destination: EKS main cluster security group
    security_group_id = module.eks.cluster_security_group_id 
    
    # Source FIXED: Replaced module.ec2 sideways reference with a single variable string
    source_security_group_id = var.bastion_security_group_id 

    lifecycle {
        # This rule should be recreated if the EKS cluster's security group changes
        create_before_destroy = true
    }
}
