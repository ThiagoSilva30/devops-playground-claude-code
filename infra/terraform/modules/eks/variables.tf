variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.36"
}

variable "cluster_role_arn" {
  description = "ARN da IAM role do cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN da IAM role dos nodes"
  type        = string
}

variable "cluster_security_group_id" {
  description = "ID do security group do cluster"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas"
  type        = list(string)
}

variable "desired_size" {
  description = "Número desejado de nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Número mínimo de nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Número máximo de nodes"
  type        = number
  default     = 4
}

variable "instance_types" {
  description = "Tipos de instância para nodes"
  type        = list(string)
  default     = ["t3.medium"]
}
