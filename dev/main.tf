variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "petclinic"
}

# Fetch the tracking identifier for the raw OS base layer image
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# ==============================================================================
# BASE NETWORKING INFRASTRUCTURE
# ==============================================================================
module "vpc_module" {
  source = "../modules/vpc"

  region           = var.region
  vpc_name         = "${var.environment}-vpc"
  igw_name         = "${var.environment}-igw"
  route_table_name = "${var.environment}-rt"
  cidr_block       = "10.0.0.0/16"

  public_subnets = {
    "public-subnet-1a" = "10.0.1.0/24"
    "public-subnet-1b" = "10.0.2.0/24"
    "public-subnet-1c" = "10.0.3.0/24"
  }

  private_subnets = {
    "private-subnet-1a" = "10.0.10.0/24"
    "private-subnet-1b" = "10.0.20.0/24"
    "private-subnet-1c" = "10.0.30.0/24"
  }

  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

  tags = {
    Environment = var.environment
    application = var.application
    managed_by  = "terraform"
  }
}

# ==============================================================================
# SECURE IDENTITY AUTHENTICATION LAYERS
# ==============================================================================
resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.environment}-${var.application}-bastion-key"
  public_key = file("~/.ssh/bastion-key.pub") 
}

# ==============================================================================
# COMPUTE LAYER: SECURE JUMP BOX ENGINE (EC2)
# ==============================================================================
module "ec2" {
  source = "../modules/ec2"

  region        = var.region
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"
  
  # Pass down network anchors so the module can build its custom security framework
  vpc_id        = module.vpc_module.vpc_id 
  subnet_id     = module.vpc_module.public_subnets["public-subnet-1a"] 
  ssh_key_name  = aws_key_pair.bastion_key.key_name 
  instance_name = "${var.environment}-${var.application}-bastion-host"
  
  # CALIBRATION FIXED: Feeds EKS state values down cleanly to form IAM profiles
  eks_cluster_arn = module.eks.eks_cluster_arn

  tags = {
    Environment = var.environment
    application = var.application
    managed_by  = "terraform"
  }
}

# ==============================================================================
# ORCHESTRATION LAYER: CONTAINER CONTROL FABRIC (EKS)
# ==============================================================================
module "eks" {
  source = "../modules/eks"

  environment                 = var.environment
  application                 = var.application
  public_access               = false
  node_group_desired_capacity = 2
  node_group_min_capacity     = 1
  node_group_max_capacity     = 3
  node_group_instance_type    = "t3.micro"
  node_group_ami_type         = "AL2023_x86_64_STANDARD" 

  # CALIBRATION FIXED: Direct module runtime outputs injected as local input arrays
  vpc_id                    = module.vpc_module.vpc_id
  private_subnet_ids        = module.vpc_module.private_subnets
  bastion_security_group_id = module.ec2.instance_security_group_id

  tags = {
    Environment = var.environment
    application = var.application
    managed_by  = "terraform"
  }
}

module "ecr" {
  source    = "../modules/ecr"
}

module "rds" {
  source = "../modules/rds"
  db_name              = local.db_username
  db_username          = local.db_username
  db_password          = local.db_password
  environment          = var.environment
  application          = var.application
  db_instance_class   = "db.t4g.micro"
  db_allocated_storage = 20
  multi_az_flag       = false
  snapshot_flag       = false

  # CALIBRATION FIXED: Direct module runtime outputs injected as local input arrays
  vpc_id             = module.vpc_module.vpc_id
  private_subnet_ids = module.vpc_module.private_subnets
  eks_node_security_group_id = module.eks.eks_node_security_group_id

  tags = {
    environment = var.environment
    application = var.application
    managed_by  = "terraform"
  }
}