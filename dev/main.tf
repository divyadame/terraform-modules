variable "region" {
  type    = string
  default = "ap-south-1"
}

module "vpc_module" {
  source = "../modules/vpc"

  # Pass all variables required by your code
  region           = var.region
  vpc_name         = "my-dev-vpc"
  igw_name         = "my-dev-igw"
  route_table_name = "my-dev-public-rt"
  cidr_block       = "10.0.0.0/16"

  # Map of subnet name to CIDR block (for your for_each)
  public_subnets = {
    "public-subnet-1a" = "10.0.1.0/24"
    "public-subnet-1b" = "10.0.2.0/24"
    "public-subnet-1c" = "10.0.3.0/24"
  }

  private_subnets = {
    "private-subnet-1a" = "10.0.10.0/24"
    "private-subnet-1b" = "10.0.20.0/24"
    "private-subnet-1c" = "10.0.30.0/24"
  }

  # List of zones used by your element() function
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

  # Base tags to merge
  tags = {
    Environment  = "dev"
    appplication = "petclinic"
    managed_by   = "terraform"
  }
}

