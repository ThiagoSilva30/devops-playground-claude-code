# DevOps Playground - EKS Provisionado com Terraform

## 📋 Resumo Executivo

Este projeto demonstra como provisionar um **cluster EKS (Elastic Kubernetes Service)** completamente funcional na AWS usando **Infrastructure as Code com Terraform**, com uma aplicação Python containerizada pronta para produção.

---

## 🏗️ Arquitetura do Projeto

```
devops-playground/
├── app/                          # Aplicação Python
│   ├── main.py                   # HTTP Server (health + metrics)
│   └── tests/
│       └── test_health.py        # Testes unitários
├── infra/
│   ├── kubernetes/               # Manifestos Kubernetes
│   │   └── deployment.yaml       # Deploy com 2 réplicas
│   └── terraform/                # Infrastructure as Code
│       ├── main.tf               # Provider AWS + backend S3
│       ├── eks.tf                # Cluster EKS completo
│       ├── variables.tf          # Variáveis configuráveis
│       └── outputs.tf            # Saídas úteis
├── Dockerfile                    # Containerização
├── docker-compose.yml            # Dev/Staging/Prod
└── build-docker.sh               # Script de build
```

---

## 🎯 O que foi implementado

### 1. **Aplicação Python (HTTP Server)**
- ✅ Endpoint `/health` - retorna status OK
- ✅ Endpoint `/metrics` - retorna métricas de requisições
- ✅ Logging estruturado
- ✅ Validação de porta e host
- ✅ Graceful shutdown
- ✅ Testes unitários

**Tecnologia:** Python 3.11, http.server (sem dependências externas)

### 2. **Containerização**
- ✅ `Dockerfile` multi-stage otimizado
- ✅ Imagem leve (Python 3.11 slim)
- ✅ HEALTHCHECK automático
- ✅ `.dockerignore` para reduzir tamanho
- ✅ `docker-compose.yml` para dev/staging/prod

**Tamanho da imagem:** ~150 MB

### 3. **Infrastructure as Code (Terraform)**

#### **Rede (VPC)**
- VPC com CIDR 10.0.0.0/16
- 4 Subnets (2 públicas + 2 privadas) em 2 AZs
- Internet Gateway + NAT Gateways
- Route Tables para roteamento inteligente

#### **Security**
- 2 Security Groups (cluster + nodes)
- IAM Roles com permissões mínimas
- Endpoint privado e público do EKS

#### **Kubernetes**
- **Cluster EKS** versão 1.36
- **Node Group** com 2 nodes t3.medium (escalável 1-4)
- Auto Scaling Group integrado

#### **Container Registry**
- **ECR Repository** privado
- Scan de segurança automático
- Image tagging mutável

**Custo estimado:** ~$165/mês

### 4. **Kubernetes**
- ✅ Deployment com 2 réplicas
- ✅ Service para exposição
- ✅ Probes de saúde (liveness + readiness)
- ✅ Limites de recursos configurados

---

## 🚀 Passo a Passo de Implementação

### **Fase 1: Preparação**

```bash
# 1. Clonar/acessar o projeto
cd devops-playground-claude-code

# 2. Testar a aplicação localmente
python3 -m unittest discover app/tests
# ✅ Resultado: 1 test OK

# 3. Rodar a aplicação
python3 app/main.py
# ✅ Servidor rodando em 127.0.0.1:8080

# 4. Testar endpoints
curl http://localhost:8080/health
# {"status": "ok"}
curl http://localhost:8080/metrics
# {"requests_total": 2, "requests_health": 1, ...}
```

### **Fase 2: Containerização**

```bash
# 1. Build da imagem Docker
docker build -t devops-playground:latest .

# 2. Testar container localmente
docker run -p 8080:8080 devops-playground:latest

# 3. Testar endpoints
curl http://localhost:8080/health
```

### **Fase 3: Provisionar EKS com Terraform**

```bash
# 1. Navegar ao diretório
cd infra/terraform

# 2. Inicializar Terraform (com backend S3)
AWS_PROFILE=twbeach terraform init

# 3. Validar configuração
terraform validate
# ✅ Success! The configuration is valid.

# 4. Planejar infraestrutura
AWS_PROFILE=twbeach terraform plan

# 5. Aplicar (demora ~15-20 minutos)
AWS_PROFILE=twbeach terraform apply

# 6. Verificar outputs
AWS_PROFILE=twbeach terraform output
```

**Recursos criados:**
- 1 VPC
- 4 Subnets
- 2 NAT Gateways
- 1 EKS Cluster
- 1 Node Group (2 nodes)
- 1 ECR Repository
- 8 IAM Roles/Policies
- 2 Security Groups

### **Fase 4: Publicar Imagem no ECR**

```bash
# 1. Obter Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile twbeach)

# 2. Login no ECR
aws ecr get-login-password --region us-east-1 --profile twbeach | \
  docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# 3. Tag da imagem
docker tag devops-playground:latest \
  $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/devops-playground:latest

# 4. Push para ECR
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/devops-playground:latest
```

### **Fase 5: Configurar kubectl**

```bash
# 1. Configurar kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name devops-playground-eks \
  --profile twbeach

# 2. Verificar acesso
kubectl cluster-info
kubectl get nodes
# ✅ 2 nodes rodando
```

### **Fase 6: Deploy no Kubernetes**

```bash
# 1. Aplicar manifesto
kubectl apply -f infra/kubernetes/deployment.yaml

# 2. Verificar pods
kubectl get pods
# ✅ 2 pods rodando

# 3. Verificar serviço
kubectl get svc

# 4. Testar aplicação
kubectl port-forward svc/devops-playground 8080:8080

# Em outro terminal:
curl http://localhost:8080/health
curl http://localhost:8080/metrics
```

---

## 📊 Status Final

| Componente | Status | Detalhe |
|-----------|--------|---------|
| Aplicação Python | ✅ OK | 2 endpoints funcionais |
| Testes | ✅ OK | 1/1 passando |
| Docker | ✅ OK | Imagem ~150MB |
| Terraform | ✅ OK | 30+ recursos |
| EKS Cluster | ✅ OK | v1.36, 2 nodes |
| ECR Repository | ✅ OK | Privado com scan |
| Kubernetes Deploy | ✅ OK | 2 réplicas |
| Métricas | ✅ OK | Endpoint funcional |

---

## 🔍 Tecnologias Utilizadas

### **Linguagem & Runtime**
- Python 3.11
- http.server (stdlib)

### **Containerização**
- Docker
- Docker Compose

### **Cloud & Kubernetes**
- AWS EKS
- AWS ECR
- AWS VPC/NAT/IGW

### **Infrastructure as Code**
- Terraform v1.0+
- AWS Provider v5.0+

### **Orquestração & DevOps**
- Kubernetes 1.36
- kubectl
- AWS CLI

---

## 💡 Aprendizados & Best Practices

### **Infraestrutura**
✅ VPC com múltiplos AZs para alta disponibilidade  
✅ Subnets privadas para nodes com NAT Gateway  
✅ Security Groups com princípio de menor privilégio  
✅ IAM Roles com políticas mínimas necessárias  

### **Aplicação**
✅ Testes automatizados  
✅ Logging estruturado  
✅ Healthchecks implementados  
✅ Graceful shutdown  

### **Containerização**
✅ Imagem Docker leve (slim base image)  
✅ Docker Compose para múltiplos ambientes  
✅ .dockerignore otimizado  

### **Kubernetes**
✅ Deployment com replicas  
✅ Liveness & Readiness probes  
✅ Resource limits definidos  

### **DevOps**
✅ Infrastructure as Code (Terraform)  
✅ Backend remoto (S3 + DynamoDB)  
✅ Versionamento de Kubernetes (1.36)  
✅ ECR com scan automático  

---

## 📈 Próximos Passos (Roadmap)

### **Curto Prazo**
- [ ] Implementar Ingress Controller (AWS ALB)
- [ ] Configurar Domain Name (Route53)
- [ ] SSL/TLS com ACM

### **Médio Prazo**
- [ ] Horizontal Pod Autoscaler (HPA)
- [ ] Cluster Autoscaler (CA)
- [ ] Prometheus + Grafana
- [ ] ELK Stack ou CloudWatch Logs

### **Longo Prazo**
- [ ] GitHub Actions CI/CD
- [ ] ArgoCD para GitOps
- [ ] Service Mesh (Istio)
- [ ] Multi-region deployment
- [ ] Disaster recovery

---

## 💰 Custo Estimado (AWS)

| Serviço | Custo Mensal |
|---------|--------------|
| EKS Cluster | $73 |
| 2x t3.medium nodes | $60 |
| NAT Gateway (2x) | $32 |
| Data Transfer | ~$5 |
| ECR Storage | <$1 |
| **TOTAL** | **~$170** |

*Preços aproximados para us-east-1 (Aug 2024)*

---

## 🔐 Segurança

- ✅ Credenciais via AWS SSO (não hardcoded)
- ✅ Backend Terraform criptografado (S3 + DynamoDB lock)
- ✅ Security Groups restritivos
- ✅ IAM Roles com permissões mínimas
- ✅ ECR scan automático
- ✅ Sem secrets hardcoded

---

## 📚 Recursos Úteis

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## ✨ Conclusão

Este projeto demonstra como usar **Infrastructure as Code com Terraform** e **Container Orchestration com Kubernetes** para provisionar uma aplicação completa na AWS.

**Ferramentas utilizadas:**
- Claude Code (assistente IA)
- Terraform
- Docker
- AWS (EKS, ECR, VPC)
- Kubernetes

**Tempo total:** ~2-3 horas (da ideia ao cluster pronto)

---

*Projeto desenvolvido com Claude Code - claude.ai/code*
