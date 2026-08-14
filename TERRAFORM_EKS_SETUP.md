# Setup EKS com Terraform - Passo a Passo

Este guia mostra como provisionar um cluster EKS (Elastic Kubernetes Service) na AWS usando Terraform.

## 📋 Pré-requisitos

1. **AWS Account** com credenciais configuradas
2. **Terraform** instalado (v1.0+)
3. **AWS CLI** instalado
4. **kubectl** instalado
5. **Docker** instalado (para build de imagens)

## 🔧 Configuração Inicial

### 1. Verificar credenciais AWS

```bash
# Verificar se as credenciais estão configuradas
aws sts get-caller-identity --profile twbeach
```

### 2. Inicializar Terraform

```bash
cd infra/terraform

# Inicializar (baixa providers e módulos)
terraform init

# Formatar código
terraform fmt

# Validar configuração
terraform validate
```

## 📐 Variáveis Customizáveis

Você pode customizar o setup editando o `terraform.tfvars` ou passando via linha de comando:

```bash
# Criar arquivo terraform.tfvars
cat > terraform.tfvars <<EOF
region               = "us-east-1"
kubernetes_version   = "1.29"
desired_size         = 2
min_size             = 1
max_size             = 4
instance_types       = ["t3.medium"]
EOF
```

## 🚀 Deployment

### 3. Planejar a infraestrutura

```bash
# Ver o que será criado/modificado
terraform plan -out=tfplan

# Ou com arquivo de variáveis
terraform plan -var-file=terraform.tfvars -out=tfplan
```

**Recurso que será criado:**
- 1 VPC
- 4 Subnets (2 públicas, 2 privadas) em 2 AZs
- Internet Gateway
- 2 NAT Gateways
- EKS Cluster
- EKS Node Group (2 nodes t3.medium)
- ECR Repository
- Security Groups e IAM Roles

### 4. Aplicar a infraestrutura

```bash
# Aplicar o plano
terraform apply tfplan

# OU aplicar direto (vai pedir confirmação)
terraform apply
```

⏱️ **Tempo estimado:** 15-20 minutos para provisionar

## 📡 Acessar o Cluster

### 5. Configurar kubeconfig

```bash
# Copiar o comando do output do Terraform
aws eks update-kubeconfig \
  --region us-east-1 \
  --name devops-playground-eks \
  --profile twbeach

# Verificar acesso
kubectl cluster-info
kubectl get nodes
```

## 📦 Deploy da Aplicação

### 6. Build e push da imagem Docker

```bash
# Fazer login no ECR
aws ecr get-login-password --region us-east-1 --profile twbeach | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build da imagem
docker build -t devops-playground:latest .

# Tag para ECR
docker tag devops-playground:latest \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/devops-playground:latest

# Push para ECR
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/devops-playground:latest
```

Substitua `<ACCOUNT_ID>` pelo seu ID da conta AWS:
```bash
# Obter ID da conta
aws sts get-caller-identity --query Account --output text --profile twbeach
```

### 7. Deploy no Kubernetes

```bash
# Atualizar a imagem no deployment
kubectl set image deployment/devops-playground \
  devops-playground=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/devops-playground:latest

# Ou aplicar o manifesto (se houver updates)
kubectl apply -f infra/kubernetes/deployment.yaml
```

## 🧪 Verificações

```bash
# Verificar pods
kubectl get pods -n default

# Verificar serviços
kubectl get svc

# Ver logs de um pod
kubectl logs -f deployment/devops-playground

# Fazer port-forward para testar localmente
kubectl port-forward svc/devops-playground 8080:8080

# Testar endpoint
curl http://localhost:8080/health
curl http://localhost:8080/metrics
```

## 🗑️ Cleanup (Destruir Infraestrutura)

```bash
# Ver o que será destruído
terraform plan -destroy

# Destruir tudo
terraform destroy

# Ou com arquivo de variáveis
terraform destroy -var-file=terraform.tfvars
```

⚠️ **Aviso:** Isto é irreversível. Todos os dados serão perdidos.

## 💰 Estimativa de Custo

**Custo mensal aproximado (us-east-1):**
- EKS Cluster: ~$73
- 2x t3.medium nodes: ~$60/mês
- NAT Gateway: ~$32
- **Total: ~$165/mês**

(Preços aproximados em 2024, verifique na calculadora AWS para valores exatos)

## 🔒 Boas Práticas de Segurança

1. **Não commitar secrets:** Use `sensitive = true` nos outputs sensíveis
2. **IAM Policies:** Use o princípio de menor privilégio
3. **Network Policy:** Configure Network Policies no Kubernetes
4. **RBAC:** Configure controle de acesso baseado em função
5. **Backups:** Implemente política de backup para dados persistentes

## 📚 Referências

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## ⚡ Troubleshooting

### Erro: "Access Denied" ao conectar ao cluster

```bash
# Verificar credenciais
aws sts get-caller-identity --profile twbeach

# Atualizar kubeconfig
aws eks update-kubeconfig --region us-east-1 --name devops-playground-eks --profile twbeach
```

### Pods ficam em Pending

```bash
# Verificar eventos
kubectl describe pod <pod-name>

# Verificar node resources
kubectl top nodes
kubectl top pods
```

### ECR Push recusa a imagem

```bash
# Re-fazer login
aws ecr get-login-password --region us-east-1 --profile twbeach | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

## 📝 Próximos Passos

- [ ] Configurar Ingress Controller (nginx, AWS ALB)
- [ ] Implementar autoscaling horizontal de pods (HPA)
- [ ] Implementar autoscaling de nodes (Cluster Autoscaler)
- [ ] Configurar monitoramento (CloudWatch, Prometheus)
- [ ] Configurar logging centralizado (CloudWatch Logs, ELK)
- [ ] Implementar CI/CD (GitHub Actions, GitLab CI)
