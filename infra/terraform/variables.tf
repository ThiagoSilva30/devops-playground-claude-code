variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID para EC2"
  default     = "ami-06e78a71af43ef21a"
}

# ====== EKS Variables ======
variable "kubernetes_version" {
  description = "Versão do Kubernetes para EKS"
  default     = "1.36"
}

variable "desired_size" {
  description = "Número desejado de nodes"
  default     = 2
}

variable "min_size" {
  description = "Número mínimo de nodes"
  default     = 1
}

variable "max_size" {
  description = "Número máximo de nodes"
  default     = 4
}

variable "instance_types" {
  description = "Tipos de instância para nodes"
  default     = ["t3.medium"]
}
