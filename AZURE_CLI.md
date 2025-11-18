# Azure CLI - Guia de Comandos

Este documento contém scripts e comandos Azure CLI para gerenciar o projeto 4JobSoftware.

## 📋 Pré-requisitos

```bash
# Instalar Azure CLI
# macOS:
brew install azure-cli

# Linux:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login
```

---

## 🚀 Scripts Disponíveis

### 1. `scripts/azure-setup.sh` - Setup Inicial

Verifica recursos e configurações básicas:

```bash
./scripts/azure-setup.sh
```

**O que faz:**
- Verifica login no Azure
- Lista Resource Groups
- Lista VMs existentes
- Lista IPs públicos

---

### 2. `scripts/azure-firewall.sh` - Configurar Firewall

Configura regras de Network Security Group (NSG):

```bash
./scripts/azure-firewall.sh
```

**O que faz:**
- Cria/atualiza NSG
- Abre portas: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (Next.js)
- Lista regras configuradas

---

### 3. `scripts/azure-vm-info.sh` - Informações da VM

Mostra informações detalhadas da VM:

```bash
./scripts/azure-vm-info.sh
```

**O que mostra:**
- Status da VM
- IP público
- Teste de conectividade
- Network Interface
- NSG associado
- Informações do disco

---

### 4. `scripts/azure-deploy-vm.sh` - Deploy Automático

Faz deploy completo da aplicação na VM:

```bash
./scripts/azure-deploy-vm.sh [VM_NAME] [RESOURCE_GROUP]
```

**Exemplo:**
```bash
./scripts/azure-deploy-vm.sh vm-4jobsoftware rg-4jobsoftware
```

**O que faz:**
- Conecta na VM via SSH
- Instala Node.js, PM2, Nginx
- Clona/atualiza projeto do GitHub
- Faz build da aplicação
- Configura Nginx
- Inicia aplicação com PM2

---

## 🔧 Comandos Úteis Azure CLI

### Verificar Login
```bash
az account show
```

### Listar Subscriptions
```bash
az account list --output table
```

### Definir Subscription
```bash
az account set --subscription "SUBSCRIPTION_ID"
```

### Listar Resource Groups
```bash
az group list --output table
```

### Criar Resource Group
```bash
az group create \
  --name rg-4jobsoftware \
  --location brazilsouth
```

### Listar VMs
```bash
az vm list --output table
az vm list --resource-group rg-4jobsoftware --output table
```

### Obter IP Público da VM
```bash
az vm show \
  --resource-group rg-4jobsoftware \
  --name vm-4jobsoftware \
  --show-details \
  --query "publicIps" -o tsv
```

### Iniciar/Parar VM
```bash
# Iniciar
az vm start --resource-group rg-4jobsoftware --name vm-4jobsoftware

# Parar
az vm stop --resource-group rg-4jobsoftware --name vm-4jobsoftware

# Reiniciar
az vm restart --resource-group rg-4jobsoftware --name vm-4jobsoftware
```

### Listar NSGs
```bash
az network nsg list --resource-group rg-4jobsoftware --output table
```

### Criar Regra NSG
```bash
az network nsg rule create \
  --resource-group rg-4jobsoftware \
  --nsg-name nsg-4jobsoftware \
  --name AllowHTTP \
  --priority 1000 \
  --protocol Tcp \
  --destination-port-ranges 80 \
  --access Allow
```

### Listar Regras NSG
```bash
az network nsg rule list \
  --resource-group rg-4jobsoftware \
  --nsg-name nsg-4jobsoftware \
  --output table
```

### Conectar via SSH
```bash
# Obter IP primeiro
IP=$(az vm show --resource-group rg-4jobsoftware --name vm-4jobsoftware --show-details --query "publicIps" -o tsv)

# Conectar
ssh azureuser@$IP
```

### Executar Comando na VM
```bash
az vm run-command invoke \
  --resource-group rg-4jobsoftware \
  --name vm-4jobsoftware \
  --command-id RunShellScript \
  --scripts "node --version"
```

---

## 🔥 Fluxo Completo de Deploy

### 1. Verificar Recursos
```bash
./scripts/azure-setup.sh
```

### 2. Configurar Firewall
```bash
./scripts/azure-firewall.sh
```

### 3. Verificar VM
```bash
./scripts/azure-vm-info.sh
```

### 4. Fazer Deploy
```bash
./scripts/azure-deploy-vm.sh
```

---

## 🐛 Troubleshooting

### Erro: "VM não encontrada"
```bash
# Listar todas as VMs
az vm list --output table

# Verificar Resource Group
az group list --output table
```

### Erro: "Não consegue conectar via SSH"
```bash
# Verificar se VM está rodando
az vm show --resource-group rg-4jobsoftware --name vm-4jobsoftware --query "powerState"

# Verificar NSG
./scripts/azure-firewall.sh
```

### Erro: "Porta não acessível"
```bash
# Verificar regras NSG
az network nsg rule list \
  --resource-group rg-4jobsoftware \
  --nsg-name nsg-4jobsoftware \
  --output table

# Criar regra manualmente
az network nsg rule create \
  --resource-group rg-4jobsoftware \
  --nsg-name nsg-4jobsoftware \
  --name AllowHTTP \
  --priority 1000 \
  --protocol Tcp \
  --destination-port-ranges 80 \
  --access Allow
```

---

## 📚 Recursos

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Azure VM Commands](https://docs.microsoft.com/cli/azure/vm)
- [Azure Network Commands](https://docs.microsoft.com/cli/azure/network)

---

**Última atualização:** Janeiro 2025

