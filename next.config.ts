import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  // Configuração para produção no Azure
  output: 'standalone', // Para Azure App Service
  // output: 'export', // Descomente para Azure Static Web Apps (se usar export)
  
  // Otimizações
  compress: true,
  poweredByHeader: false,
  
  // Configuração de imagens
  images: {
    unoptimized: false, // Azure Static Web Apps requer true
  },
}

export default nextConfig

