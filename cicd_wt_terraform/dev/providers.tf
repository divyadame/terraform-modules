terraform {
    required_version = "~> 1.14.9"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    
    }
backend "s3" {
    bucket = "terraform-bucket-petclinic"
    key = "dev/ec2.tfstate"
    region = "ap-south-1"
    encrypt = true
    use_lockfile = true
}
}

provider "aws" {
    region = var.region
}

