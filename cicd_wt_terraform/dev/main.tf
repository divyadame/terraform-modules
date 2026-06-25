
variable "region" {
    type = string
    default = "ap-south-1"
}

variable "ssh_public_key" {
    type = string
}


module "ec2_instance" {
    source = "../ec2"
    instance_type = "t3.micro"
    tags = {
        managed_by = "terraform"
        environment = "dev"
    }
    ssh_public_key = var.ssh_public_key
}

module "s3_dev" {
    source = "../s3"
    bucket_config = {
        "dev" = {
          env = "dev"
          name = "dev_bucket" 
        }
    }

}