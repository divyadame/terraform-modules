variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "ssh_public_key" {
    type = string
    description = "Injected from GitHub vars"
}

variable "tags" {
    type = map(string)
    default = {
        managed_by  = "terraform"
        environment = "dev"
    }
}