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
resource "aws_iam_role" "ec2_s3_role" {
  name               = "EC2-S3-IAM-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 4. Define the Custom S3 Policy for All Buckets
data "aws_iam_policy_document" "s3_access" {
  statement {
    sid = "ListObjectsInBucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3::*"  # FIXED: Removed the extra colon for global bucket scoping
    ]
  }

  statement {
    sid = "ReadWriteObjects"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::*/*"  # FIXED: Added /* to correctly target the objects inside the buckets
    ]
  }
}

# 5. Create the Custom S3 IAM Policy
resource "aws_iam_policy" "s3_policy" {
  name        = "EC2-S3-Access-Policy"
  description = "Allows EC2 instance to read and write to S3 buckets"
  policy      = data.aws_iam_policy_document.s3_access.json
}

# 6. Attach the Custom S3 Policy to the Role
resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# 7. Create the Instance Profile (The wrapper required by EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-S3-Instance-Profile" # OPTIONAL CLEANUP: Removed "SSM" from the name since SSM policy was removed
  role = aws_iam_role.ec2_s3_role.name
}
