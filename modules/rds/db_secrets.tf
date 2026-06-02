resource "aws_secretsmanager_secret" "rds_secret" {
    name = "${var.environment}-${var.application}-db-credentials"
    description = "RDS database credentials for ${var.application} in ${var.environment} environment"
    tags = merge(
        var.tags,
        {
            "Name" = "${var.environment}-${var.application}-db-credentials"
        }
    )
}

resource "aws_secretsmanager_secret_version" "rds_creds" {
    secret_id     = aws_secretsmanager_secret.rds_secret.id
    secret_string = jsonencode({
        username = var.db_username
        password = var.db_password
        db_name  = var.db_name
    })
}