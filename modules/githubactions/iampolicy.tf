# 1. Fetch AWS Account Details & GitHub OIDC TLS Thumbprint
data "aws_caller_identity" "current" {}



# 2. Reference the Existing IAM OIDC Identity Provider (FIXED)
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 3. Create the Trust Policy Document - Define the Trust Rules
data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

# Only Github actions allowed to assume this policy, with conditions on the repository and audience
    principals {
      type        = "Federated"
      # FIXED: Changed from resource reference to data source reference
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# 4. Create the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name               = var.githubactionsrole
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
}

# 5. Create Permissions Policy for ECR and EKS
resource "aws_iam_policy" "github_permissions" {
  name        = "github-actions-ecr-eks-permissions"
  description = "Permissions for GitHub Actions to push to ECR and deploy to EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/${var.environment}-${var.application}-repo"
      },
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster"
        ]
        Resource = "arn:aws:eks:us-east-1:${data.aws_caller_identity.current.account_id}:cluster/${var.environment}-${var.application}-cluster"
      }
    ]
  })
}

# 6. Attach Permissions to the GitHub IAM Role
resource "aws_iam_role_policy_attachment" "github_policy_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_permissions.arn
}


