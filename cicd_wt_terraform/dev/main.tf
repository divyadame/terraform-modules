
module "ec2_instance" {
    source = "../ec2"
    instance_type = "t3.micro"
    tags = {
        managed_by = "terraform"
        environment = "dev"
    }
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