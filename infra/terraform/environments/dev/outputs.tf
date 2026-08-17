# VPC Outputs
output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

# EKS Outputs
output "eks_cluster_id" {
  description = "ID do cluster EKS"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "ARN do cluster EKS"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint do API server do EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Versão do Kubernetes"
  value       = module.eks.cluster_version
}

output "eks_cluster_certificate_authority" {
  description = "Certificate Authority do EKS"
  value       = module.eks.cluster_certificate_authority
  sensitive   = true
}

output "configure_kubectl" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name} --profile twbeach"
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN do repositório ECR"
  value       = module.ecr.repository_arn
}
