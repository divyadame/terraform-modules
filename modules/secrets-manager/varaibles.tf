variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "petclinic"
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

variable "tags" {
  type = map(string)
  default = {
    application = "test-petclinic" 
    managed_by  = "terraform"  
  }
}