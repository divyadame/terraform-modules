# Variable for your specific repository
variable "github_repo" {
  description = "Name of Github Repo in org/repo format"
  type        = string
  default     = "divyadame/aws-devops-divya-projects-java-rds"
}

# Variables for resource naming interpolation
variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "my-app"
}

variable "githubactionsrole" {
    type = string
    default = "dev-petclinic-github"
 }