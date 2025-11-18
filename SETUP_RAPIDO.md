# 🚀 Setup Rápido - Servidor Azure

## ⚠️ Problema Identificado

O DNS está apontando para: **68.211.147.93** (não 20.206.241.156)

## ✅ Solução Rápida

### Passo 1: Conectar no Servidor Azure

```bash
ssh usuario@20.206.241.156
# ou se o IP mudou:
ssh usuario@68.211.147.93
```

### Passo 2: Executar Setup Automático

Copie e cole este script completo no servidor:

```bash
#!/bin/bash
set -e

echo "🚀 Configurando 4JobSoftware no servidor..."

# 1. Instalar Node.js 20
if ! command -v node &> /dev/null; then
    echo "📦 Instalando Node.js 20..."
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

# 4. Criar diretório e clonar projeto
if [ ! -d "/var/www/4jobsoftware" ]; then
    echo "📥 Clonando repositório..."
    sudo mkdir -p /var/www
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

# Habilitar site
sudo ln -sf /etc/nginx/sites-available/4jobsoftware /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Testar e recarregar Nginx
sudo nginx -t && sudo systemctl reload nginx

# 6. Iniciar aplicação com PM2
echo "🚀 Iniciando aplicação..."
cd /var/www/4jobsoftware
pm2 delete 4jobsoftware 2>/dev/null || true
pm2 start npm --name "4jobsoftware" -- start
pm2 save
pm2 startup

echo ""
echo "✅ Configuração concluída!"
echo "🌐 Teste localmente: curl http://localhost:3000"
echo "📊 Status PM2: pm2 list"
echo "📝 Logs: pm2 logs 4jobsoftware"
```

**Salvar como arquivo e executar:**
```bash
nano setup.sh
# Cole o script acima
chmod +x setup.sh
sudo ./setup.sh
```

---

## 🔍 Verificação Pós-Setup

### 1. Verificar se Next.js está rodando
```bash
pm2 list
# Deve mostrar: 4jobsoftware | online
```

### 2. Testar localmente no servidor
```bash
curl http://localhost:3000
# Deve retornar HTML da página
```

### 3. Verificar Nginx
```bash
sudo systemctl status nginx
sudo nginx -t
```

### 4. Verificar logs
```bash
pm2 logs 4jobsoftware --lines 20
sudo tail -20 /var/log/nginx/error.log
```

---

## 🔥 Comandos Úteis

### Reiniciar aplicação
```bash
pm2 restart 4jobsoftware
```

### Ver logs em tempo real
```bash
pm2 logs 4jobsoftware
```

### Atualizar código
```bash
cd /var/www/4jobsoftware
git pull
npm ci
npm run build
pm2 restart 4jobsoftware
```

### Verificar portas abertas
```bash
sudo netstat -tulpn | grep -E "3000|80|443"
```

---

## 🛡️ Configurar Firewall Azure

No portal Azure, verifique se as portas estão abertas:

1. **Network Security Groups** > Seu NSG
2. **Inbound rules** devem ter:
   - Porta 80 (HTTP) - Allow
   - Porta 443 (HTTPS) - Allow
   - Porta 22 (SSH) - Allow

---

## 📞 Se Ainda Não Funcionar

1. **Verifique o IP do servidor:**
```bash
hostname -I
# ou
curl ifconfig.me
```

2. **Atualize o DNS** para apontar para o IP correto

3. **Aguarde propagação DNS** (pode levar até 24h)

4. **Teste diretamente pelo IP:**
```bash
curl http://SEU_IP_AQUI
```

---

**Última atualização:** Janeiro 2025

