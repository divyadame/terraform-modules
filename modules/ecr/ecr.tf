# ==============================================================================
# CONTAINER REPOSITORY REGISTRY (ECR) - INLINE FABRIC
# ==============================================================================
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
}
 variable "application" {
  description = "The name of the application (e.g., petclinic)"
  type        = string
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.environment}-${var.application}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}


