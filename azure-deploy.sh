#!/bin/bash

# Script de deploy manual para Azure
# Uso: ./azure-deploy.sh

set -e

echo "🚀 Iniciando deploy para Azure..."

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se está logado no Azure
echo -e "${BLUE}Verificando login no Azure...${NC}"
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute: az login"
    exit 1
fi

# Build do projeto
echo -e "${BLUE}Construindo projeto Next.js...${NC}"
npm ci
npm run build

echo -e "${GREEN}✅ Build concluído!${NC}"

# Verificar se Azure Static Web Apps está configurado
echo -e "${BLUE}Para deploy automático via Azure Static Web Apps:${NC}"
echo "1. Configure o GitHub Actions com o token AZURE_STATIC_WEB_APPS_API_TOKEN"
echo "2. Ou use: az staticwebapp deploy"
echo ""
echo -e "${BLUE}Para deploy manual no servidor Azure (IP: 20.206.241.156):${NC}"
echo "1. Copie os arquivos .next para o servidor"
echo "2. Configure o Nginx para servir o Next.js"
echo "3. Execute: npm start no servidor"

echo -e "${GREEN}✅ Script concluído!${NC}"

