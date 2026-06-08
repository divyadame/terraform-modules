resource "aws_vpc" "main" {
    cidr_block           = var.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = merge(var.tags, {
        Name = var.vpc_name
    })
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = merge(var.tags, {
        Name = var.igw_name
    })
}

# ==============================================================================
# NETWORKING: PUBLIC ROUTING
# ==============================================================================
#Create Public Route table with route
#that directs all internet outbound traffic thru internet GW
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = merge(var.tags, {
        Name = "${var.route_table_name}-public"
    })
}

#create public subnets in the VPC
resource "aws_subnet" "public" {
    for_each          = var.public_subnets
    vpc_id            = aws_vpc.main.id
    cidr_block        = each.value
    # Automatically map a public IP on launch so the Bastion Host is reachable
    map_public_ip_on_launch = true 
    availability_zone = element(var.availability_zones, index(keys(var.public_subnets), each.key))
    tags = merge(var.tags, {
        Name = each.key
        # Crucial for EKS Public/External Load Balancers
        "kubernetes.io/role/elb" = "1"
    })
}

#Associate Above public subnets and route_table
resource "aws_route_table_association" "public" {
    for_each       = var.public_subnets
    subnet_id      = aws_subnet.public[each.key].id
    route_table_id = aws_route_table.public.id
}

# ==============================================================================
# NETWORKING: NAT GATEWAY (Crucial for Private EKS Nodes)
# ==============================================================================
# resource "aws_eip" "nat" {
#     domain = "vpc"
#     tags   = merge(var.tags, { Name = "${var.vpc_name}-nat-eip" })
# }

# resource "aws_nat_gateway" "main" {
#     allocation_id = aws_eip.nat.id
#     # Deploy the NAT gateway inside your first available public subnet
#     subnet_id     = aws_subnet.public[keys(var.public_subnets)[0]].id 
#     tags          = merge(var.tags, { Name = "${var.vpc_name}-nat-gateway" })

#     # Explicit dependency to ensure clean creation/destruction sequencing
#     depends_on = [aws_internet_gateway.main] 
# }

# ==============================================================================
# NETWORKING: PRIVATE ROUTING (FIXED: Outbound internet via NAT Gateway)
# ==============================================================================
# resource "aws_route_table" "private" {
#     vpc_id = aws_vpc.main.id
#     route {
#         cidr_block     = "0.0.0.0/0"
#         nat_gateway_id = aws_nat_gateway.main.id
#     }
#     tags = merge(var.tags, {
#         Name = "${var.route_table_name}-private"
#     })
# }

#Create private subnets
resource "aws_subnet" "private" {
    for_each          = var.private_subnets
    vpc_id            = aws_vpc.main.id
    cidr_block        = each.value
    availability_zone = element(var.availability_zones, index(keys(var.private_subnets), each.key))
    tags = merge(var.tags, {
        Name = each.key
        
        "kubernetes.io/role/internal-elb" = "1"
    })
}

# resource "aws_route_table_association" "private" {
#     for_each       = var.private_subnets
#     subnet_id      = aws_subnet.private[each.key].id
#     route_table_id = aws_route_table.private.id
# }


