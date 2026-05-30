variable region {
    description = "The AWS region to create the VPC in"
    type = string
    default = "us-east-1"
}

variable availability_zones {
    description = "The availability zones to create the subnets in"
    type = list(string)
    default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable tags {
    description = "The tag to identify the VPC"
    type = map(string)
    default = {
        environment = "test"
        appplication = "test-petclinic" 
        managed_by = "terraform"  }
}

variable vpc_name {
    description = "The name of the VPC"
    type = string
    default = "my_test_vpc"
}

variable cidr_block {
    description = "The CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable igw_name {
    description = "The name of the Internet Gateway"
    type = string
    default = "my_test_igw"
}

variable route_table_name {
    description = "The name of the Route Table"
    type = string
    default = "my_test_route_table"
}

variable public_subnets {
    description = "The name of the public subnet 1"
    type = map(string)
    default = {
        public_subnet_1 = "10.0.1.0/24"
        public_subnet_2 = "10.0.2.0/24"
        public_subnet_3 = "10.0.3.0/24"
        }
}

variable private_subnets {
    description = "The name of the private subnet 1"
    type = map(string)
    default = {
        private_subnet_1 = "10.0.10.0/24"
        private_subnet_2 = "10.0.20.0/24"
        private_subnet_3 = "10.0.30.0/24"
        }
}
