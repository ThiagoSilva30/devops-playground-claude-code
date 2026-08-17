variable "repository_name" {
  description = "Nome do repositório ECR"
  type        = string
}

variable "image_tag_mutability" {
  description = "Mutabilidade das tags de imagem"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Escanear imagem ao fazer push"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Habilitar política de ciclo de vida"
  type        = bool
  default     = true
}
