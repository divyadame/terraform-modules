resource "aws_key_pair" "this" {
    key_name = "ec2_key"
    public_key = file("~/.ssh/bastion-key.pub")
}

resource "aws_security_group" "this" {
    name = "testing"
    description = "testing"
    vpc_id = data.aws_vpc.default.id
}

#Ingress for ec2 sg
resource "aws_security_group_rule" "this" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["49.207.149.45/32"]
    security_group_id = aws_security_group.this.id
}

#egress for ec2 sg
resource "aws_security_group_rule" "instance_egress" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.this.id
}

# Rule B: Allows SSH from the EICE Gateway Security Group (via Private Network)
resource "aws_security_group_rule" "eice_ssh" {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.eice_sg.id # Links EICE to Instance
    security_group_id        = aws_security_group.this.id
}

# 2. SEPARATE Security Group for the EICE Gateway
resource "aws_security_group" "eice_sg" {
    name        = "eice-gateway-sg"
    description = "Control traffic leaving the EICE gateway"
    vpc_id      = data.aws_vpc.default.id
}

# EICE needs an outbound rule to send traffic to your instance subnet
resource "aws_security_group_rule" "eice_egress" {
    type              = "egress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = [data.aws_vpc.default.cidr_block] # Allows reaching internal resources
    security_group_id = aws_security_group.eice_sg.id
}


# 4. EC2 Instance Configuration
resource "aws_instance" "this" {
    ami = data.aws_ssm_parameter.al2023_ami.value
    instance_type = "t3.micro"
    key_name = aws_key_pair.this.key_name
    subnet_id = data.aws_subnets.this.ids[0]
    vpc_security_group_ids = [aws_security_group.this.id]
    iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
    tags = {
        managed_by = "terraform"
    }

}

# 4. Create the EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = data.aws_subnets.this.ids[0]
  security_group_ids = [aws_security_group.eice_sg.id]

    tags = {
        managed_by = "terraform"
    }
}