#!/bin/bash

# Script para fazer deploy da aplicação na VM Azure
# Uso: ./scripts/azure-deploy-vm.sh [VM_NAME] [RESOURCE_GROUP]

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

VM_NAME=${1:-"vm-4jobsoftware"}
RESOURCE_GROUP=${2:-"rg-4jobsoftware"}

echo -e "${BLUE}🚀 Deploy da aplicação na VM Azure${NC}"
echo ""

# Verificar login
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute: az login"
    exit 1
fi

# Obter IP público da VM
echo -e "${BLUE}Obtendo IP público da VM...${NC}"
PUBLIC_IP=$(az vm show \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --show-details \
    --query "publicIps" -o tsv)

if [ -z "$PUBLIC_IP" ]; then
    echo "❌ Não foi possível obter o IP público da VM"
    exit 1
fi

echo -e "${GREEN}✅ IP Público: $PUBLIC_IP${NC}"
echo ""

# Obter usuário SSH (tentar diferentes padrões)
SSH_USER="azureuser"
echo -e "${BLUE}Usuário SSH: $SSH_USER${NC}"
echo ""

# Criar script de deploy para executar na VM
DEPLOY_SCRIPT=$(cat <<'SCRIPT'
#!/bin/bash
set -e

echo "🚀 Iniciando deploy da 4JobSoftware..."

# Instalar Node.js se não estiver instalado
if ! command -v node &> /dev/null; then
    echo "📦 Instalando Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Instalar PM2 se não estiver instalado
if ! command -v pm2 &> /dev/null; then
    echo "📦 Instalando PM2..."
    sudo npm install -g pm2
fi

# Instalar Nginx se não estiver instalado
if ! command -v nginx &> /dev/null; then
    echo "📦 Instalando Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# Criar diretório se não existir
sudo mkdir -p /var/www
cd /var/www

# Clonar ou atualizar projeto
if [ -d "4jobsoftware" ]; then
    echo "🔄 Atualizando projeto..."
    cd 4jobsoftware
    sudo git pull
else
    echo "📥 Clonando projeto..."
    sudo git clone https://github.com/Crowcba/4jobsoftware.git
    cd 4jobsoftware
fi

# Instalar dependências e build
echo "🔨 Instalando dependências e fazendo build..."
sudo npm ci
sudo npm run build

# Configurar Nginx
echo "⚙️ Configurando Nginx..."
sudo tee /etc/nginx/sites-available/4jobsoftware > /dev/null <<'EOF'
server {
    listen 80;
    server_name 4jobsoftware.com.br www.4jobsoftware.com.br;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/4jobsoftware /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# Iniciar aplicação com PM2
echo "🚀 Iniciando aplicação..."
pm2 delete 4jobsoftware 2>/dev/null || true
pm2 start npm --name "4jobsoftware" -- start
pm2 save
pm2 startup

echo ""
echo "✅ Deploy concluído!"
echo "🌐 Teste: curl http://localhost:3000"
SCRIPT
)

# Salvar script temporário
TEMP_SCRIPT="/tmp/deploy-4jobsoftware.sh"
echo "$DEPLOY_SCRIPT" > $TEMP_SCRIPT
chmod +x $TEMP_SCRIPT

echo -e "${BLUE}Enviando script para a VM...${NC}"
scp -o StrictHostKeyChecking=no $TEMP_SCRIPT ${SSH_USER}@${PUBLIC_IP}:/tmp/

echo -e "${BLUE}Executando deploy na VM...${NC}"
ssh -o StrictHostKeyChecking=no ${SSH_USER}@${PUBLIC_IP} "bash /tmp/deploy-4jobsoftware.sh"

# Limpar
rm -f $TEMP_SCRIPT

echo ""
echo -e "${GREEN}✅ Deploy concluído!${NC}"
echo ""
echo "🌐 Acesse: http://$PUBLIC_IP"
echo "🌐 Ou: http://4jobsoftware.com.br (se DNS configurado)"

