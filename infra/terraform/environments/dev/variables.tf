variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks para subnets privadas"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.36"
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

variable "ecr_image_tag_mutability" {
  description = "Mutabilidade das tags no ECR"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Escanear imagens ao fazer push no ECR"
  type        = bool
  default     = true
}

variable "ecr_enable_lifecycle_policy" {
  description = "Habilitar política de ciclo de vida no ECR"
  type        = bool
  default     = true
}
