#!/bin/bash

# Script para configurar Firewall (NSG) no Azure
# Uso: ./scripts/azure-firewall.sh

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔥 Configurando Firewall (NSG) no Azure${NC}"
echo ""

# Verificar login
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute: az login"
    exit 1
fi

# Configurações (ajuste conforme necessário)
RESOURCE_GROUP="rg-4jobsoftware"
NSG_NAME="nsg-4jobsoftware"

# Listar NSGs existentes
echo -e "${BLUE}Network Security Groups existentes:${NC}"
az network nsg list \
    --resource-group $RESOURCE_GROUP \
    --output table \
    2>/dev/null || echo "Nenhum NSG encontrado no resource group"

echo ""

# Perguntar qual NSG configurar
read -p "Nome do NSG para configurar (ou Enter para criar novo): " NSG_INPUT
if [ ! -z "$NSG_INPUT" ]; then
    NSG_NAME=$NSG_INPUT
fi

# Criar NSG se não existir
echo -e "${BLUE}Criando/Verificando NSG: $NSG_NAME${NC}"
az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name $NSG_NAME \
    --location brazilsouth \
    --output none 2>/dev/null || echo "NSG já existe"

# Regras de Firewall
echo ""
echo -e "${BLUE}Configurando regras de firewall...${NC}"

# SSH (Porta 22)
echo "📡 Configurando SSH (porta 22)..."
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowSSH \
    --priority 1000 \
    --protocol Tcp \
    --destination-port-ranges 22 \
    --access Allow \
    --output none 2>/dev/null || \
az network nsg rule update \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowSSH \
    --access Allow \
    --output none

# HTTP (Porta 80)
echo "🌐 Configurando HTTP (porta 80)..."
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowHTTP \
    --priority 1001 \
    --protocol Tcp \
    --destination-port-ranges 80 \
    --access Allow \
    --output none 2>/dev/null || \
az network nsg rule update \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowHTTP \
    --access Allow \
    --output none

# HTTPS (Porta 443)
echo "🔒 Configurando HTTPS (porta 443)..."
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowHTTPS \
    --priority 1002 \
    --protocol Tcp \
    --destination-port-ranges 443 \
    --access Allow \
    --output none 2>/dev/null || \
az network nsg rule update \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowHTTPS \
    --access Allow \
    --output none

# Next.js (Porta 3000) - apenas para desenvolvimento
echo "⚛️  Configurando Next.js (porta 3000)..."
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowNextJS \
    --priority 1003 \
    --protocol Tcp \
    --destination-port-ranges 3000 \
    --access Allow \
    --output none 2>/dev/null || \
az network nsg rule update \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowNextJS \
    --access Allow \
    --output none

echo ""
echo -e "${GREEN}✅ Regras de firewall configuradas!${NC}"

# Listar regras
echo ""
echo -e "${BLUE}Regras configuradas:${NC}"
az network nsg rule list \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --output table

echo ""
echo -e "${YELLOW}💡 Dica: Associe este NSG à sua VM ou Subnet${NC}"

