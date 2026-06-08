# 7. Output the Role ARN to use in your GitHub Workflow
output "github-actions-role-arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "Copy this ARN into your GitHub Actions workflow configuration"
}