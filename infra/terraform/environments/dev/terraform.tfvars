region     = "us-east-1"
environment = "dev"

vpc_cidr_block       = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24"]

kubernetes_version = "1.36"

desired_size   = 2
min_size       = 1
max_size       = 4
instance_types = ["t3.medium"]

ecr_image_tag_mutability   = "MUTABLE"
ecr_scan_on_push           = true
ecr_enable_lifecycle_policy = true
