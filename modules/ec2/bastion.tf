# ==============================================================================
# 1. THE BASTION EC2 VIRTUAL MACHINE
# ==============================================================================
resource "aws_instance" "ec2" {
    ami           = var.ami
    instance_type = var.instance_type
    subnet_id     = var.subnet_id
    vpc_security_group_ids = [aws_security_group.bastion_sg.id] 
    key_name               = var.ssh_key_name

    # FIXED: Attach the IAM instance profile created down below
    iam_instance_profile   = aws_iam_instance_profile.bastion_instance_profile.name

    tags = merge(var.tags, {
        "Name" = var.instance_name
    })
}

