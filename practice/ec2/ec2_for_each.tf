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


variable "ec2_instances" {
    type = list(object({
       name = string,
       size = string
    }))
    default = [
        { name = "web", size = "t3.micro" },
        { name = "qa", size = "t3.medium" }
    ]
}

# 4. Single EC2 Instance Configuration
resource "aws_instance" "this" {
     # Converts list(object) into a map(object) using item.name as the key
    for_each = { for ec2 in var.ec2_instances : ec2.name => ec2 }
    ami = data.aws_ssm_parameter.al2023_ami.value
    instance_type = each.value.size
    key_name = aws_key_pair.this.key_name
    subnet_id = data.aws_subnets.this.ids[0]
    vpc_security_group_ids = [aws_security_group.this.id]
    iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
    tags = {
        managed_by = "terraform"
        Name = each.key
    }
    # # 1. Prevents accidental deletion via AWS Console / CLI
    # disable_api_termination = true 

    # # 2. Keeps your data volume safe even if the server is destroyed
    # root_block_device {
    #     delete_on_termination = false 
    # }

}

