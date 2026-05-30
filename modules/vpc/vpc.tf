resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = merge(var.tags, 
    {
        Name = var.vpc_name
    })
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = merge (var.tags, {
        Name = var.igw_name
    })
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = merge(var.tags,{
        Name = "${var.route_table_name}-public"
    })
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = merge(var.tags,{
        Name = "${var.route_table_name}-private"
    })
}
resource "aws_subnet" "public" {
    for_each = var.public_subnets
    vpc_id = aws_vpc.main.id
    cidr_block = each.value
    availability_zone = element(var.availability_zones, index(keys(var.public_subnets), each.key))
    tags = merge(var.tags,{
        Name = each.key
    })
}

resource "aws_subnet" "private" {
    for_each = var.private_subnets
    vpc_id = aws_vpc.main.id
    cidr_block = each.value
    availability_zone = element(var.availability_zones, index(keys(var.private_subnets), each.key))
    tags = merge (var.tags,{
        Name = each.key
    })
}

resource "aws_route_table_association" "public" {
    for_each = var.public_subnets
    subnet_id = aws_subnet.public[each.key].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    for_each = var.private_subnets
    subnet_id = aws_subnet.private[each.key].id
    route_table_id = aws_route_table.private.id
}