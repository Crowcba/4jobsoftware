# Troubleshooting - 4JobSoftware

## 🔴 Erro: ERR_CONNECTION_TIMED_OUT

Este erro indica que o DNS está funcionando, mas o servidor não está respondendo.

### Diagnóstico Rápido

1. **Verificar se o servidor está acessível:**
```bash
ping 20.206.241.156
```

2. **Verificar se a porta 80/443 está aberta:**
```bash
curl -I http://20.206.241.156
curl -I https://20.206.241.156
```

3. **Verificar DNS:**
```bash
nslookup 4jobsoftware.com.br
# Deve retornar: 20.206.241.156
```

---

## ✅ Checklist de Verificação no Servidor

### 1. Conectar no Servidor Azure

```bash
ssh usuario@20.206.241.156
```

### 2. Verificar se Node.js está instalado

```bash
node --version
# Deve retornar: v20.x.x ou superior

npm --version
```

**Se não estiver instalado:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 3. Verificar se o projeto está no servidor

```bash
ls -la /var/www/4jobsoftware
# ou
ls -la ~/4jobsoftware
```

**Se não estiver, clonar:**
```bash
cd /var/www
sudo git clone https://github.com/Crowcba/4jobsoftware.git
cd 4jobsoftware
sudo npm ci
sudo npm run build
```

### 4. Verificar se o Next.js está rodando

```bash
# Verificar processos Node.js
ps aux | grep node

# Verificar PM2 (se estiver usando)
pm2 list
pm2 logs 4jobsoftware
```

**Se não estiver rodando, iniciar:**
```bash
cd /var/www/4jobsoftware
npm run build
pm2 start npm --name "4jobsoftware" -- start
pm2 save
pm2 startup
```

**Ou sem PM2:**
```bash
cd /var/www/4jobsoftware
npm run build
nohup npm start > /var/log/4jobsoftware.log 2>&1 &
```

### 5. Verificar se Nginx está configurado

```bash
# Verificar se Nginx está rodando
sudo systemctl status nginx

# Verificar configuração
sudo cat /etc/nginx/sites-available/4jobsoftware
sudo cat /etc/nginx/sites-enabled/4jobsoftware
```

**Criar configuração do Nginx:**
```bash
sudo nano /etc/nginx/sites-available/4jobsoftware
```

**Conteúdo:**
```nginx
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
```

**Habilitar e reiniciar:**
```bash
sudo ln -s /etc/nginx/sites-available/4jobsoftware /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 6. Verificar Firewall (Azure NSG)

No portal Azure:
1. Vá em **Network Security Groups**
2. Encontre o NSG associado ao servidor
3. Verifique se há regras permitindo:
   - **Porta 80** (HTTP) - Inbound
   - **Porta 443** (HTTPS) - Inbound
   - **Porta 22** (SSH) - Inbound

**Criar regras via CLI:**
```bash
az network nsg rule create \
  --resource-group SEU_RESOURCE_GROUP \
  --nsg-name SEU_NSG \
  --name AllowHTTP \
  --priority 1000 \
  --protocol Tcp \
  --destination-port-ranges 80 \
  --access Allow

az network nsg rule create \
  --resource-group SEU_RESOURCE_GROUP \
  --nsg-name SEU_NSG \
  --name AllowHTTPS \
  --priority 1001 \
  --protocol Tcp \
  --destination-port-ranges 443 \
  --access Allow
```

### 7. Verificar se a porta 3000 está acessível localmente

```bash
# No servidor
curl http://localhost:3000

# Deve retornar HTML da página
```

**Se não funcionar:**
```bash
# Verificar se algo está usando a porta 3000
sudo netstat -tulpn | grep 3000

# Matar processo se necessário
sudo kill -9 PID_DO_PROCESSO
```

---

## 🚀 Script de Setup Completo

Crie um arquivo `setup-server.sh` no servidor:

```bash
#!/bin/bash

set -e

echo "🚀 Configurando servidor para 4JobSoftware..."

# 1. Instalar Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Instalando Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 2. Instalar PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 Instalando PM2..."
    sudo npm install -g pm2
fi

# 3. Instalar Nginx
if ! command -v nginx &> /dev/null; then
    echo "📦 Instalando Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# 4. Clonar projeto
if [ ! -d "/var/www/4jobsoftware" ]; then
    echo "📥 Clonando repositório..."
    cd /var/www
    sudo git clone https://github.com/Crowcba/4jobsoftware.git
    cd 4jobsoftware
    sudo npm ci
    sudo npm run build
else
    echo "🔄 Atualizando projeto..."
    cd /var/www/4jobsoftware
    sudo git pull
    sudo npm ci
    sudo npm run build
fi

# 5. Configurar Nginx
echo "⚙️ Configurando Nginx..."
sudo tee /etc/nginx/sites-available/4jobsoftware > /dev/null <<EOF
server {
    listen 80;
    server_name 4jobsoftware.com.br www.4jobsoftware.com.br;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/4jobsoftware /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 6. Iniciar aplicação com PM2
echo "🚀 Iniciando aplicação..."
cd /var/www/4jobsoftware
pm2 delete 4jobsoftware 2>/dev/null || true
pm2 start npm --name "4jobsoftware" -- start
pm2 save
pm2 startup

echo "✅ Configuração concluída!"
echo "🌐 Acesse: http://4jobsoftware.com.br"
```

**Executar:**
```bash
chmod +x setup-server.sh
sudo ./setup-server.sh
```

---

## 🔍 Comandos de Diagnóstico

### Verificar logs do Next.js
```bash
pm2 logs 4jobsoftware --lines 50
```

### Verificar logs do Nginx
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Verificar processos
```bash
ps aux | grep -E "node|nginx|pm2"
```

### Testar conectividade
```bash
# Do seu computador local
curl -v http://4jobsoftware.com.br
curl -v http://20.206.241.156
```

---

## 📞 Próximos Passos

1. **Conecte no servidor:** `ssh usuario@20.206.241.156`
2. **Execute o script de setup** ou siga o checklist manualmente
3. **Verifique os logs** se ainda houver problemas
4. **Teste localmente** no servidor: `curl http://localhost:3000`

---

**Última atualização:** Janeiro 2025

