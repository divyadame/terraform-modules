output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.main.id
}

output "public_subnets_ids" {
    description = "map of tags to public subnet ids"
    value = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnets_ids" {
    description = "map of tags to private subnet ids"
    value = { for k, v in aws_subnet.private : k => v.id }
}

output "route_gateway_id" {
    description = "The ID for IGW"
    value = aws_internet_gateway.main.id
}