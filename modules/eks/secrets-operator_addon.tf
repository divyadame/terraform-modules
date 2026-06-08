/* External Secrets Operator (ESO) automatically monitors AWS Secrets Manager, 
safely reads your database strings, and dynamically synchronizes them into 
native Kubernetes secrets. Your application can then instantly read them 
as standard Environment Variables. */

# ==============================================================================
# 1. AWS IAM POLICY FOR DB SECRETS
# ==============================================================================
resource "aws_iam_policy" "app_db_secrets" {
  name        = "${var.environment}-${var.application}-db-secrets-policy"
  description = "Allows External Secrets Operator to read app database credentials"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        # Restrict this to your specific DB secret ARN for tight production security
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.environment}-${var.application}-db-*"
      }
    ]
  })
}

# ==============================================================================
# 2. POD IDENTITY ASSOCIATIVE BRIDGE
# ==============================================================================
module "app_secrets_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  name = "${var.environment}-${var.application}-app-secrets-manager"

  additional_policy_arns = {
    db_access = aws_iam_policy.app_db_secrets.arn
  }

  associations = {
    app_secrets = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system" 
      service_account = "external-secrets" # Binds to the central ESO engine
    }
  }
}

# ==============================================================================
# DEPLOY EXTERNAL SECRETS OPERATOR ENGINE
# ==============================================================================
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system" # Must match the namespace in your pod identity!
  version    = "0.14.0"      # Uses a stable production version

  # Crucial: Installs the custom Kubernetes objects (CRDs) required by the engine
  set = [
    {
    name  = "installCRDs"
    value = "true"
    },

  # Crucial: Links the software to the service account your Pod Identity is watching
   {
    name  = "serviceAccount.name"
    value = "external-secrets"
   }
  ]

  # Forces Terraform to wait until your EKS cluster and IAM security role exist
  depends_on = [
    module.eks, 
    module.app_secrets_pod_identity
  ]
}
