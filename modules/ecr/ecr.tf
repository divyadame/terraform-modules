# ==============================================================================
# CONTAINER REPOSITORY REGISTRY (ECR) - INLINE FABRIC
# ==============================================================================
resource "aws_ecr_repository" "this" {
  name                 = "petclinic-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}


