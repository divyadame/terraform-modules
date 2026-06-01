# 1. Create the Security Group inside the EC2 module
resource "aws_security_group" "bastion_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group managed completely by the EC2 module"
  vpc_id      = var.vpc_id # Needs the VPC ID to know where to build it

  # Inbound SSH rule
  ingress {
    description = "Allow inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet rule (Needed to install kubectl)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.instance_name}-sg"
  })
}

