output "repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "ARN do repositório ECR"
  value       = aws_ecr_repository.app.arn
}

output "repository_name" {
  description = "Nome do repositório ECR"
  value       = aws_ecr_repository.app.name
}

output "registry_id" {
  description = "ID do registro ECR"
  value       = aws_ecr_repository.app.registry_id
}
