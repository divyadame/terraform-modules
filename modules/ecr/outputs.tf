output "repo_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "The URL of the created repository"
}