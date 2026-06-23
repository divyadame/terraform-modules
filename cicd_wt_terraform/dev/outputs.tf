output "public_ip" {
    value = module.ec2_instance.public_ip
}

output "ec2_instance_id" {
  description = "The ID of the provisioned EC2 instance"
  value       = module.ec2_instance.ec2_instance_id
}

output "dev_s3_bucket_id" {
    value = module.s3_dev.s3_bucket_names
}