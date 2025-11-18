#!/bin/bash

# Script de configuração Azure via CLI
# Uso: ./scripts/azure-setup.sh

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Configurando Azure para 4JobSoftware${NC}"
echo ""

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI não está instalado."
    echo "Instale em: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar login
echo -e "${BLUE}Verificando login no Azure...${NC}"
if ! az account show &> /dev/null; then
    echo "⚠️  Não está logado. Fazendo login..."
    az login
fi

# Obter informações da conta
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo -e "${GREEN}✅ Logado no Azure${NC}"
echo "   Subscription: $SUBSCRIPTION_ID"
echo ""

# Configurações (ajuste conforme necessário)
RESOURCE_GROUP="rg-4jobsoftware"
LOCATION="brazilsouth"
VM_NAME="vm-4jobsoftware"
NSG_NAME="nsg-4jobsoftware"
VNET_NAME="vnet-4jobsoftware"
SUBNET_NAME="subnet-default"
PUBLIC_IP_NAME="ip-4jobsoftware"

# Criar Resource Group
echo -e "${BLUE}Criando Resource Group...${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output none
echo -e "${GREEN}✅ Resource Group criado${NC}"

# Listar VMs existentes
echo ""
echo -e "${BLUE}VMs existentes no Resource Group:${NC}"
az vm list \
    --resource-group $RESOURCE_GROUP \
    --output table \
    2>/dev/null || echo "Nenhuma VM encontrada"

# Listar IPs públicos
echo ""
echo -e "${BLUE}IPs Públicos:${NC}"
az network public-ip list \
    --resource-group $RESOURCE_GROUP \
    --output table \
    2>/dev/null || echo "Nenhum IP público encontrado"

echo ""
echo -e "${GREEN}✅ Verificação concluída!${NC}"

