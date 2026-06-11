# 1. Define the Trust Policy (Allows EC2 to assume this role)
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. Create the IAM Role
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "EC2-SSM-Core-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 3. Attach the AWS-Managed SSM Policy to the Role
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Create the Instance Profile (The wrapper required by EC2)
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "EC2-SSM-Core-Profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# # 5. Associate the Profile with your existing EC2 Instance
# resource "aws_ec2_instance_iam_instance_profile_association" "ssm_association" {
#   instance_id          = "i-09141615d237742c1"
#   iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
# }
## Referenced the instance profile dynamically right here:
