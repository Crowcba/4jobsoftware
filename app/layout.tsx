import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: '4JobSoftware - Engenharia de Software | Sistemas Customizados',
  description: 'Engenharia de software especializada em sistemas customizados para empresas e soluções próprias. Transforme suas ideias em realidade digital.',
  keywords: 'engenharia de software, sistemas customizados, desenvolvimento de software, soluções empresariais',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/imagens/icone.ico" />
      </head>
      <body suppressHydrationWarning>{children}</body>
    </html>
  )
}

