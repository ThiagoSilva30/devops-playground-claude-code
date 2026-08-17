output "eks_cluster_role_arn" {
  description = "ARN da IAM role do EKS cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "ARN da IAM role dos EKS nodes"
  value       = aws_iam_role.eks_node.arn
}

output "eks_cluster_role_name" {
  description = "Nome da IAM role do EKS cluster"
  value       = aws_iam_role.eks_cluster.name
}

output "eks_node_role_name" {
  description = "Nome da IAM role dos EKS nodes"
  value       = aws_iam_role.eks_node.name
}
