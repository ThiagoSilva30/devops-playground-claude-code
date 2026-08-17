output "eks_cluster_security_group_id" {
  description = "ID do security group do EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "ID do security group dos EKS nodes"
  value       = aws_security_group.eks_nodes.id
}
