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
      Environment = "eks"
      ManagedBy   = "terraform"
    }
  }
}
