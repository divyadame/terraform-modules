variable "vpc_id" {
  description = "The ID of the VPC from the VPC module."
  type        = string
}

variable "private_subnet_ids" {
  description = "The list of private subnets for EKS worker nodes."
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "The security group ID of the bastion host to allow ingress."
  type        = string
}

variable "cluster_name" { 
  type    = string
  default = "my-eks-cluster" 
}

variable "environment" { 
  type    = string
  default = "dev" 
}

variable "application" { 
  type    = string
  default = "petclinic" 
}

variable "public_access" { 
  type    = bool
  default = false 
}

variable "node_group_desired_capacity" { 
  type    = number
  default = 2 
}

variable "node_group_min_capacity" { 
  type    = number
  default = 1 
}   

variable "node_group_max_capacity" { 
  type    = number
  default = 3 
}

variable "node_group_instance_type" { 
  type    = string
  default = "t3.micro" 
}

variable "node_group_ami_type" { 
  type    = string
  default = "AL2023_x86_64_STANDARD" 
}

variable "node_group_capacity_type" { 
  type    = string
  default = "SPOT" 
}

variable "tags" {
  type = map(string)
  default = {
    application = "test-petclinic" 
    managed_by  = "terraform"  
  }
}
