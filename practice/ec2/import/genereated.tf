# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_instance" "imported_instance" {
  ami                                  = "ami-0db56f446d44f2f09"
  associate_public_ip_address          = true
  availability_zone                    = "ap-south-1c"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.micro"
  ipv6_address_count                   = 0
  ipv6_addresses                       = []
  key_name                             = "ec2_key"
  monitoring                           = false
  placement_partition_number           = 0
  private_ip                           = "172.31.29.153"
  secondary_private_ips                = []
  security_groups                      = ["testing"]
  source_dest_check                    = true
  subnet_id                            = "subnet-01ef067e5b989506f"
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
  tags_all = {
    environment = "test"
    managed_by  = "terraform"
  }
  tenancy                     = "default"
  user_data_replace_on_change = null
  volume_tags                 = null
  vpc_security_group_ids      = ["sg-0def5ec9e8df1b3ca"]
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  enclave_options {
    enabled = false
  }
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 8
    volume_type           = "gp3"
  }
}
