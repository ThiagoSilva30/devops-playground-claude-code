terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops50-playground-terraform-state"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  profile = "twbeach"
  region  = var.region

  default_tags {
    tags = {
      Project     = "devops-playground"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Data source para availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # EKS suporta apenas essas AZs em us-east-1
  eks_supported_azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1f"
  ]
  # Usar apenas as AZs que EKS suporta
  azs_for_eks = [for az in data.aws_availability_zones.available.names : az if contains(local.eks_supported_azs, az)]
}
# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name                  = "${local.project_name}-vpc"
  cidr_block            = var.vpc_cidr_block
  availability_zones    = slice(local.azs_for_eks, 0, 2)
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
}

# Security Module
module "security" {
  source = "../../modules/security"

  name     = local.project_name
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  name = local.project_name
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name               = "${local.project_name}-eks"
  kubernetes_version         = var.kubernetes_version
  cluster_role_arn           = module.iam.eks_cluster_role_arn
  node_role_arn              = module.iam.eks_node_role_arn
  cluster_security_group_id  = module.security.eks_cluster_security_group_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  private_subnet_ids         = module.vpc.private_subnet_ids
  desired_size               = var.desired_size
  min_size                   = var.min_size
  max_size                   = var.max_size
  instance_types             = var.instance_types
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  repository_name        = "${local.project_name}-app"
  image_tag_mutability   = var.ecr_image_tag_mutability
  scan_on_push           = var.ecr_scan_on_push
  enable_lifecycle_policy = var.ecr_enable_lifecycle_policy
}
