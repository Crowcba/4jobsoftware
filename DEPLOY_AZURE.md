# Deploy no Azure - 4JobSoftware

Este documento contém instruções para fazer deploy da landing page no Azure.

## 📋 Pré-requisitos

- Conta Azure ativa
- Azure CLI instalado (`az --version`)
- DNS configurado apontando para `20.206.241.156`

## 🚀 Opções de Deploy

### Opção 1: Azure Static Web Apps (Recomendado)

Azure Static Web Apps é ideal para Next.js e oferece:
- ✅ Deploy automático via GitHub Actions
- ✅ SSL automático
- ✅ CDN global
- ✅ Custom domain support

#### Passo a Passo:

1. **Criar Static Web App no Azure:**

```bash
# Login no Azure
az login

# Criar resource group (se não existir)
az group create --name rg-4jobsoftware --location brazilsouth

# Criar Static Web App
az staticwebapp create \
  --name 4jobsoftware-app \
  --resource-group rg-4jobsoftware \
  --location "East US 2" \
  --sku Free
```

2. **Configurar GitHub Actions:**

- No portal Azure, vá em Static Web App > Deployment token
- Copie o token
- No GitHub, vá em Settings > Secrets > Actions
- Adicione secret: `AZURE_STATIC_WEB_APPS_API_TOKEN` com o token copiado

3. **Configurar Custom Domain:**

```bash
# Adicionar domínio customizado
az staticwebapp hostname set \
  --name 4jobsoftware-app \
  --resource-group rg-4jobsoftware \
  --hostname 4jobsoftware.com.br
```

---

### Opção 2: Azure App Service

Para deploy no servidor Azure existente (20.206.241.156):

#### Configuração no Servidor:

1. **SSH no servidor:**

```bash
ssh usuario@20.206.241.156
```

2. **Instalar Node.js 20:**

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

3. **Clonar e configurar projeto:**

```bash
cd /var/www
git clone https://github.com/Crowcba/4jobsoftware.git
cd 4jobsoftware
npm ci
npm run build
```

4. **Configurar PM2 (Process Manager):**

```bash
sudo npm install -g pm2
pm2 start npm --name "4jobsoftware" -- start
pm2 save
pm2 startup
```

5. **Configurar Nginx:**

```nginx
# /etc/nginx/sites-available/4jobsoftware
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

```bash
# Habilitar site
sudo ln -s /etc/nginx/sites-available/4jobsoftware /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

6. **Configurar SSL (Let's Encrypt):**

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d 4jobsoftware.com.br -d www.4jobsoftware.com.br
```

---

### Opção 3: Deploy via GitHub Actions (Automático)

O arquivo `.github/workflows/azure-deploy.yml` já está configurado.

**Configurar secrets no GitHub:**
1. Vá em: Settings > Secrets and variables > Actions
2. Adicione: `AZURE_STATIC_WEB_APPS_API_TOKEN`

O deploy será automático a cada push na branch `main`.

---

## 🔧 Configuração do Next.js para Produção

O `next.config.ts` já está otimizado. Para produção, certifique-se de:

```typescript
// next.config.ts
const nextConfig: NextConfig = {
  output: 'standalone', // Para Azure App Service
  // ou
  // output: 'export', // Para Static Web Apps (se usar export)
}
```

---

## 📝 Variáveis de Ambiente

Se necessário, configure no Azure Portal:
- **Static Web Apps:** Configuration > Application settings
- **App Service:** Configuration > Application settings

---

## ✅ Verificação Pós-Deploy

1. Acesse: `https://4jobsoftware.com.br`
2. Verifique se todas as imagens carregam
3. Teste responsividade mobile
4. Verifique console do navegador (F12) para erros

---

## 🐛 Troubleshooting

### Erro 502 Bad Gateway
- Verifique se o Next.js está rodando: `pm2 list`
- Verifique logs: `pm2 logs 4jobsoftware`

### Imagens não carregam
- Verifique se `/public/imagens/` está no servidor
- Verifique permissões: `chmod -R 755 public/`

### Erro de build
- Verifique Node.js version: `node --version` (deve ser 20.x)
- Limpe cache: `rm -rf .next node_modules && npm ci`

---

## 📚 Recursos

- [Azure Static Web Apps Docs](https://docs.microsoft.com/azure/static-web-apps/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)

---

**Última atualização:** Janeiro 2025

