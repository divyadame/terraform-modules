output "public_ip" {
    value = aws_instance.this.public_ip
}

output "ec2_instance_id" {
  description = "The ID of the provisioned EC2 instance"
  value       = aws_instance.this.id # Change 'my_server' to match your resource local name
}
