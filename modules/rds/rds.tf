
# 1. Pass the decoded values into your RDS resource block
resource "aws_db_instance" "rds" {
    identifier              = "${var.environment}-${var.application}-db"
    engine                  = "postgres"
    engine_version          = "16.1"
    instance_class          = var.db_instance_class
    allocated_storage       = var.db_allocated_storage
#  max_allocated_storage   = var.db_max_allocated_storage
    db_name                 = var.db_name
    username                = var.db_username
    password                = var.db_password
    db_subnet_group_name    = aws_db_subnet_group.rds.name
    vpc_security_group_ids  = [aws_security_group.rds.id]
    skip_final_snapshot     = var.snapshot_flag
    publicly_accessible     = false
    multi_az                = var.multi_az_flag
    tags = merge(
        var.tags,
        {
            "Name" = "${var.environment}-${var.application}-db"
        }
    )

  
}

#If you want to pull secrets from AWS secrets manager
# 1. Locate the secret container in AWS
# data "aws_secretsmanager_secret" "rds_secret" {
#     name = "${var.environment}-${var.application}-db-credentials"

# }

# # 2. Retrieve the secret value (username and password). 
# #Pull the JSON data string from the container
# data "aws_secretsmanager_secret_version" "rds_creds" {
#     secret_id = data.aws_secretsmanager_secret.rds_secret.id
# }

# # 3. Decode the JSON string so Terraform can read individual keys
# locals {
#     db_creds = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string)
# }