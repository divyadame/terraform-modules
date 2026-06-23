# 1. Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# 2. Fetch subnets using the default VPC's ID (No more var.vpc_id!)
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id] # Linked directly to the data source above
  }
}

data "aws_subnet" "this" {
    for_each = toset(data.aws_subnets.this.ids)
    id = each.value
}

# Queries the official AWS Parameter Store for the latest x86_64 AL2023 AMI
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# 3. View the values on your screen
output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.this.ids
}

output "cidr_blocks" {
    value = [ for s in data.aws_subnet.this : s.cidr_block ]
}

output "subnet_maps" {
    value = { for s in data.aws_subnet.this : s.id => s.cidr_block }
}

output "ami" {
    value =  data.aws_ssm_parameter.al2023_ami.value
    sensitive = true
}