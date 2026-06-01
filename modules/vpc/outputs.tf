
# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================
output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.main.id
}

output "public_subnets" {
    description = "Map of tags to public subnet IDs"
    value       = { for k, v in aws_subnet.public : k => v.id }
}

# FIXED: Outputs a List of strings instead of a Map, matching what EKS expects
output "private_subnets" {
    description = "List of private subnet IDs for EKS node groups"
    value       = values({ for k, v in aws_subnet.private : k => v.id })
}

output "route_gateway_id" {
    description = "The ID for IGW"
    value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
    description = "The ID of the NAT Gateway"
    value       = aws_nat_gateway.main.id
}