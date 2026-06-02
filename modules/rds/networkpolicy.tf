resource "aws_db_subnet_group" "rds" {
    name = "${var.environment}-${var.application}-db-subnet-group"
    subnet_ids = var.private_subnet_ids
    description = "Private Subnet group for RDS instance"
    tags = merge(
        var.tags,
        {
            "Name" = "${var.environment}-${var.application}-db-subnet-group"
        }
    )
}

resource "aws_security_group" "rds" {
    name        = "${var.environment}-${var.application}-db-sg"
    description = "Security group for RDS instance"
    vpc_id      = var.vpc_id
    ingress {
        description = "Allow traffic from EKS worker nodes"
        from_port   = 5432
        to_port     = 5432  
        protocol    = "tcp"
        security_groups = [var.eks_node_security_group_id]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = merge(
        var.tags,
        {
            "Name" = "${var.environment}-${var.application}-db-sg"
        }
    )
}