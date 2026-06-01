# ==============================================================================
# MODULE VARIABLES
# ==============================================================================
variable "region" {
    type    = string
    default = "ap-south-1"
}

variable "availability_zones" {
    type    = list(string)
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "tags" {
    type    = map(string)
    default = {
        environment = "test"
        application = "test-petclinic" 
        managed_by  = "terraform"  
    }
}

variable "vpc_name" {
    type    = string
    default = "my_test_vpc"
}

variable "cidr_block" {
    type    = string
    default = "10.0.0.0/16"
}

variable "igw_name" {
    type    = string
    default = "my_test_igw"
}

variable "route_table_name" {
    type    = string
    default = "my_test_route_table"
}

# FIXED: Added the missing declaration variable to fix the evaluation crash
variable "public_security_group_name" {
    type        = string
    description = "The name given to the public security group"
    default     = "my-public-security-group"
}

variable "nat_gateway_name" {
    type        = string
    description = "The name given to the NAT Gateway"
    default     = "my-nat-gateway"
}

variable "public_subnets" {
    type    = map(string)
    default = {
        public_subnet_1 = "10.0.1.0/24"
        public_subnet_2 = "10.0.2.0/24"
        public_subnet_3 = "10.0.3.0/24"
    }
}

variable "private_subnets" {
    type    = map(string)
    default = {
        private_subnet_1 = "10.0.10.0/24"
        private_subnet_2 = "10.0.20.0/24"
        private_subnet_3 = "10.0.30.0/24"
    }
}
