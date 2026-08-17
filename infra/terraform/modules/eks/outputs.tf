output "cluster_id" {
  description = "ID do cluster EKS"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "ARN do cluster EKS"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint do API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Versão do Kubernetes"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority" {
  description = "Certificate Authority do cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_name" {
  description = "Nome do cluster"
  value       = aws_eks_cluster.main.name
}

output "node_group_id" {
  description = "ID do node group"
  value       = aws_eks_node_group.main.id
}
