variable "environment" {
  description = "The environment for the RDS instance (e.g., dev, staging, prod)."
  type        = string
}

variable "application" {
  description = "The name of the application using the RDS instance."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the RDS instance."
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "The security group ID of the EKS worker nodes that will access the RDS instance."
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance (e.g., db.t3.micro)."
  type        = string
  default     = "db.t4g.micro" # AWS Graviton (cost-effective for testing)
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS instance."
  type        = number
  default     = 20
}

variable "snapshot_flag" {
  description = "Whether to skip the final snapshot when deleting the RDS instance."
  type        = bool
  default     = true
}

variable "multi_az_flag" {
  description = "Whether to enable Multi-AZ deployment for the RDS instance."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the RDS instance."
  type        = map(string)
}

variable "db_username" {
  description = "The username for the RDS instance, retrieved from Secrets Manager."
  type        = string
}

variable "db_password" {
  description = "The password for the RDS instance, retrieved from Secrets Manager."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the initial database to create in the RDS instance, retrieved from Secrets Manager."
  type        = string
}

variable "engine" {
  description = "Select mysql,Postgres engines for your RDS"
  type        = string
}

variable "engine_version" {
  description = "Select Engine Version"
  type        = string
}