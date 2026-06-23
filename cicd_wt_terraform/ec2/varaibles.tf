variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "tags" {
    type = map(string)
    default = {
        managed_by  = "terraform"
        environment = "dev"
    }
}