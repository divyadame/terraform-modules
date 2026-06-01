variable "region" {
  type        = string
  description = "The AWS region where the EC2 instance will be launched"
  default     = "ap-south-1"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the EC2 instance will be launched"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the EC2 instance will be launched"
}

variable "ami" {
  type        = string
  description = "The ID of the AMI to use for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The type of the EC2 instance"
  default     = "t3.micro"
}

variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key pair to use for the EC2 instance"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the EC2 instance"
  default     = {}
}

variable "instance_name" {
  type        = string
  description = "The value for the Name tag of the EC2 instance"
}

variable "eks_cluster_arn" {
  type        = string
  description = "The ARN of the EKS cluster for IAM policies"
}
