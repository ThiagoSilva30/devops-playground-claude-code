# Terraform Infrastructure

Infraestrutura AWS gerenciada por Terraform seguindo as boas práticas de modularização.

## Estrutura do Projeto

```
terraform/
├── modules/                    # Módulos reutilizáveis
│   ├── vpc/                   # Módulo VPC com subnets, NAT e route tables
│   ├── security/              # Security groups para EKS
│   ├── iam/                   # IAM roles e policies
│   ├── eks/                   # Cluster EKS e node groups
│   └── ecr/                   # Repositório ECR
├── environments/              # Configurações por ambiente
│   └── dev/                   # Ambiente desenvolvimento
│       ├── main.tf           # Chamada dos módulos
│       ├── variables.tf      # Variáveis do ambiente
│       ├── outputs.tf        # Outputs do ambiente
│       ├── locals.tf         # Valores locais
│       └── terraform.tfvars  # Valores padrão das variáveis
└── README.md                 # Este arquivo
```

## Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Credenciais AWS com perfil `twbeach`
- S3 bucket para state: `devops50-playground-terraform-state`
- DynamoDB table para lock: `terraform-lock`

## Módulos

### VPC Module
Cria a infraestrutura de rede:
- VPC com CIDR configurável
- Subnets públicas e privadas em múltiplas AZs
- Internet Gateway
- NAT Gateways para saída de tráfego das subnets privadas
- Route tables e associações

**Inputs:**
- `name`: Nome base dos recursos
- `cidr_block`: CIDR block da VPC (default: 10.0.0.0/16)
- `availability_zones`: Lista de AZs
- `public_subnet_cidrs`: CIDR blocks das subnets públicas
- `private_subnet_cidrs`: CIDR blocks das subnets privadas

**Outputs:**
- `vpc_id`, `vpc_cidr`
- `public_subnet_ids`, `private_subnet_ids`
- `nat_gateway_ips`, `internet_gateway_id`

### Security Module
Cria security groups para EKS:
- Security group do cluster
- Security group dos nodes
- Regras de ingress/egress apropriadas

**Inputs:**
- `name`: Nome base dos security groups
- `vpc_id`: ID da VPC
- `vpc_cidr`: CIDR block da VPC

**Outputs:**
- `eks_cluster_security_group_id`
- `eks_nodes_security_group_id`

### IAM Module
Cria IAM roles necessárias:
- Role para EKS cluster
- Role para EKS nodes com policies:
  - AmazonEKSWorkerNodePolicy
  - AmazonEKS_CNI_Policy
  - AmazonEC2ContainerRegistryReadOnly
  - AmazonSSMManagedInstanceCore

**Inputs:**
- `name`: Nome base das roles

**Outputs:**
- `eks_cluster_role_arn`, `eks_cluster_role_name`
- `eks_node_role_arn`, `eks_node_role_name`

### EKS Module
Cria cluster EKS:
- Cluster com versão do Kubernetes configurável
- Node group com auto-scaling
- Endpoints públicos e privados

**Inputs:**
- `cluster_name`: Nome do cluster
- `kubernetes_version`: Versão do Kubernetes (default: 1.36)
- `cluster_role_arn`, `node_role_arn`: ARNs das IAM roles
- `cluster_security_group_id`: Security group do cluster
- `public_subnet_ids`, `private_subnet_ids`: Subnets
- `desired_size`, `min_size`, `max_size`: Configuração de auto-scaling
- `instance_types`: Tipos de instância (default: t3.medium)

**Outputs:**
- `cluster_id`, `cluster_arn`, `cluster_endpoint`
- `cluster_version`, `cluster_certificate_authority`
- `cluster_name`, `node_group_id`

### ECR Module
Cria repositório ECR:
- Repositório privado
- Scan de imagens ao fazer push
- Política de ciclo de vida (mantém últimas 10 imagens)

**Inputs:**
- `repository_name`: Nome do repositório
- `image_tag_mutability`: MUTABLE ou IMMUTABLE (default: MUTABLE)
- `scan_on_push`: Ativar scan (default: true)
- `enable_lifecycle_policy`: Ativar política de ciclo de vida (default: true)

**Outputs:**
- `repository_url`, `repository_arn`
- `repository_name`, `registry_id`

## Como Usar

### Inicializar Terraform
```bash
cd environments/dev
terraform init
```

### Planejar as mudanças
```bash
terraform plan
```

### Aplicar a configuração
```bash
terraform apply
```

### Destruir recursos (cuidado!)
```bash
terraform destroy
```

## Variáveis Principais

Editáveis em `environments/dev/terraform.tfvars`:

```hcl
region               = "us-east-1"
environment          = "dev"
vpc_cidr_block       = "10.0.0.0/16"
kubernetes_version   = "1.36"
desired_size         = 2
instance_types       = ["t3.medium"]
ecr_scan_on_push     = true
```

## Configurar kubectl

Após aplicar, configure kubectl:
```bash
aws eks update-kubeconfig --region us-east-1 --name devops-playground-eks --profile twbeach
```

Ou use o output `configure_kubectl`:
```bash
terraform output configure_kubectl
```

## Best Practices Implementadas

✅ Modularização: Cada componente em seu próprio módulo
✅ Variáveis: Configurações centralizadas e reutilizáveis
✅ Ambientes: Estrutura pronta para múltiplos ambientes (dev, staging, prod)
✅ Estado remoto: Armazenado em S3 com lock no DynamoDB
✅ Default tags: Tags automáticas em todos os recursos
✅ Dados sensíveis: Outputs sensíveis marcados com `sensitive = true`
✅ Documentação: Descrições em variáveis e outputs
✅ Nomes descritivos: Convenção clara de nomenclatura
✅ Múltiplas AZs: Alta disponibilidade com subnets em diferentes AZs
✅ Políticas mínimas: IAM policies restritivas ao necessário

## Troubleshooting

### Error: Backend initialization required
```bash
terraform init -backend-config="bucket=devops50-playground-terraform-state"
```

### Error: Access denied to S3 bucket
Verifique credenciais AWS e perfil `twbeach`:
```bash
aws sts get-caller-identity --profile twbeach
```

### Importar recursos existentes
```bash
terraform import aws_eks_cluster.main devops-playground-eks
```

## Próximos Passos

- [ ] Adicionar módulo de RDS
- [ ] Criar ambientes staging e prod
- [ ] Implementar IRSA (IAM Roles for Service Accounts)
- [ ] Adicionar Autoscaler e Monitoring
- [ ] Configurar backup e disaster recovery
