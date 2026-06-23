resource "aws_key_pair" "this" {
  key_name   = "ec2_key"
  public_key = file("~/.ssh/bastion-key.pub")
}

resource "aws_security_group" "this" {
  name        = "dev"
  description = "dev"
  vpc_id      = data.aws_vpc.default.id
}

# Ingress for ec2 sg
resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["49.207.149.45/32"]
  security_group_id = aws_security_group.this.id
}

# Egress for ec2 sg
resource "aws_security_group_rule" "instance_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

# 4. EC2 Instance Configuration
resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  # FIXED: Accessing the attribute list using the correct element() function
  subnet_id = element(data.aws_subnets.this.ids, 0)

  # FIXED: Reference updated to match your IAM profile block name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    managed_by  = "terraform"
    environment = "dev"
  }
}
