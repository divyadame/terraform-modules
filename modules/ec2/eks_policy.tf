# ==============================================================================
# 2. IAM BOUNDARIES (Gives the EC2 machine permission to look at EKS)
# ==============================================================================

# FIXED: Changed resource type to 'aws_iam_role'
resource "aws_iam_role" "bastion_role" {
  name = "${var.instance_name}-role"

  # FIXED: Corrected principal string typo "://amazonaws.com" to "ec2.amazonaws.com"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" 
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_bastion_policy" {
    name        = "${var.instance_name}-eks-policy"
    description = "Allows bastion to describe EKS cluster for kubeconfig token generation"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "eks:DescribeCluster"
                ]
                # FIXED: Removed 'module.eks' reference. Swapped for a variable.
                Resource = [var.eks_cluster_arn] 
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_bastion_policy_attachment" {
    role       = aws_iam_role.bastion_role.name
    policy_arn = aws_iam_policy.eks_bastion_policy.arn
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
    name = "${var.instance_name}-profile"
    role = aws_iam_role.bastion_role.name
}


