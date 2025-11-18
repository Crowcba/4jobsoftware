#!/bin/bash

# Script para obter informações da VM no Azure
# Uso: ./scripts/azure-vm-info.sh

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📊 Informações da VM no Azure${NC}"
echo ""

# Verificar login
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute: az login"
    exit 1
fi

RESOURCE_GROUP="rg-4jobsoftware"

# Listar todas as VMs
echo -e "${BLUE}VMs no Resource Group '$RESOURCE_GROUP':${NC}"
VMS=$(az vm list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv)

if [ -z "$VMS" ]; then
    echo "⚠️  Nenhuma VM encontrada no resource group"
    echo ""
    echo "Resource Groups disponíveis:"
    az group list --output table
    exit 0
fi

echo "$VMS"
echo ""

# Para cada VM, mostrar informações
for VM_NAME in $VMS; do
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}VM: $VM_NAME${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    
    # Status da VM
    echo ""
    echo -e "${BLUE}Status:${NC}"
    az vm show \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --show-details \
        --query "{Status:powerState, Location:location, Size:hardwareProfile.vmSize}" \
        --output table
    
    # IP Público
    echo ""
    echo -e "${BLUE}IP Público:${NC}"
    PUBLIC_IP=$(az vm show \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --show-details \
        --query "publicIps" -o tsv)
    
    if [ ! -z "$PUBLIC_IP" ]; then
        echo "  🌐 $PUBLIC_IP"
        echo ""
        echo "  Teste de conectividade:"
        if curl -s --connect-timeout 3 http://$PUBLIC_IP > /dev/null 2>&1; then
            echo -e "  ${GREEN}✅ Servidor respondendo${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Servidor não está respondendo${NC}"
        fi
    else
        echo "  ⚠️  Nenhum IP público encontrado"
    fi
    
    # Network Interface
    echo ""
    echo -e "${BLUE}Network Interface:${NC}"
    NIC_ID=$(az vm show \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --query "networkProfile.networkInterfaces[0].id" -o tsv)
    
    if [ ! -z "$NIC_ID" ]; then
        NIC_NAME=$(basename $NIC_ID)
        echo "  📡 $NIC_NAME"
        
        # NSG associado
        NSG_ID=$(az network nic show \
            --ids $NIC_ID \
            --query "networkSecurityGroup.id" -o tsv)
        
        if [ ! -z "$NSG_ID" ]; then
            NSG_NAME=$(basename $NSG_ID)
            echo "  🔥 NSG: $NSG_NAME"
        fi
    fi
    
    # Disco
    echo ""
    echo -e "${BLUE}Disco:${NC}"
    az vm show \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --query "storageProfile.osDisk.{Name:name, Size:diskSizeGB, Type:managedDisk.storageAccountType}" \
        --output table
    
    echo ""
done

echo ""
echo -e "${GREEN}✅ Informações exibidas!${NC}"

