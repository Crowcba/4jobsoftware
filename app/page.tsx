import styles from './page.module.css'
import { 
  Laptop, 
  Rocket, 
  Wrench, 
  RefreshCw, 
  MessageCircle, 
  Mail,
  ArrowRight
} from 'lucide-react'

export default function Home() {
  const whatsappNumber = '5565981338458'
  const whatsappMessage = encodeURIComponent('Olá! Gostaria de saber mais sobre os serviços da 4JobSoftware.')
  const whatsappUrl = `https://wa.me/${whatsappNumber}?text=${whatsappMessage}`

  return (
    <div className={styles.page}>
      {/* Header/Navigation */}
      <header className={styles.header}>
        <nav className={styles.nav}>
          <div className={styles.logoContainer}>
            <img
              src="/imagens/logo.svg"
              alt="4JobSoftware Logo"
              width={120}
              height={40}
              className={styles.logo}
            />
          </div>
          <a 
            href={whatsappUrl}
            target="_blank"
            rel="noopener noreferrer"
            className={styles.ctaButton}
          >
            Fale Conosco
          </a>
        </nav>
      </header>

      {/* Hero Section */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <h1 className={styles.heroTitle}>
            <span className={styles.titleMain}>Transforme suas ideias</span>
            <span className={styles.titleSub}>em realidade digital</span>
          </h1>
          <p className={styles.heroDescription}>
            Engenharia de software especializada em sistemas customizados para empresas 
            e soluções próprias. Desenvolvemos tecnologia que impulsiona seu negócio.
          </p>
          <div className={styles.heroButtons}>
            <a 
              href={whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className={styles.buttonPrimary}
            >
              Solicitar Orçamento
            </a>
            <a 
              href="#servicos"
              className={styles.buttonSecondary}
            >
              Conheça Nossos Serviços
            </a>
          </div>
        </div>
      </section>

      {/* Serviços Section */}
      <section id="servicos" className={styles.servicos}>
        <div className={styles.container}>
          <h2 className={styles.sectionTitle}>Nossos Serviços</h2>
          <p className={styles.sectionDescription}>
            Soluções completas em engenharia de software para empresas de todos os tamanhos
          </p>
          <div className={styles.servicesGrid}>
            <div className={styles.serviceCard}>
              <div className={styles.serviceIcon}>
                <Laptop size={48} strokeWidth={1.5} />
              </div>
              <h3 className={styles.serviceTitle}>Sistemas Customizados</h3>
              <p className={styles.serviceDescription}>
                Desenvolvemos sistemas sob medida para atender às necessidades específicas 
                da sua empresa, garantindo máxima eficiência e produtividade.
              </p>
            </div>
            <div className={styles.serviceCard}>
              <div className={styles.serviceIcon}>
                <Rocket size={48} strokeWidth={1.5} />
              </div>
              <h3 className={styles.serviceTitle}>Soluções Próprias</h3>
              <p className={styles.serviceDescription}>
                Criamos soluções inovadoras próprias que podem ser comercializadas ou 
                utilizadas internamente, agregando valor ao seu negócio.
              </p>
            </div>
            <div className={styles.serviceCard}>
              <div className={styles.serviceIcon}>
                <Wrench size={48} strokeWidth={1.5} />
              </div>
              <h3 className={styles.serviceTitle}>Consultoria Técnica</h3>
              <p className={styles.serviceDescription}>
                Oferecemos consultoria especializada para ajudar sua empresa a tomar 
                decisões tecnológicas estratégicas e implementar soluções eficazes.
              </p>
            </div>
            <div className={styles.serviceCard}>
              <div className={styles.serviceIcon}>
                <RefreshCw size={48} strokeWidth={1.5} />
              </div>
              <h3 className={styles.serviceTitle}>Manutenção e Suporte</h3>
              <p className={styles.serviceDescription}>
                Suporte contínuo e manutenção preventiva para garantir que seus sistemas 
                estejam sempre funcionando perfeitamente.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Sobre Section */}
      <section className={styles.sobre}>
        <div className={styles.container}>
          <div className={styles.sobreContent}>
            <div className={styles.sobreText}>
              <h2 className={styles.sectionTitle}>Sobre a 4JobSoftware</h2>
              <p className={styles.sobreDescription}>
                Somos uma engenharia de software focada em criar soluções tecnológicas 
                que realmente fazem a diferença. Com experiência em desenvolvimento 
                customizado e criação de produtos próprios, ajudamos empresas a 
                transformar desafios em oportunidades através da tecnologia.
              </p>
              <p className={styles.sobreDescription}>
                Nossa abordagem combina expertise técnica, atenção aos detalhes e 
                compromisso com a excelência, garantindo que cada projeto seja entregue 
                com qualidade superior e dentro do prazo estabelecido.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Contato Section */}
      <section id="contato" className={styles.contato}>
        <div className={styles.container}>
          <h2 className={styles.sectionTitle}>Entre em Contato</h2>
          <p className={styles.sectionDescription}>
            Estamos prontos para transformar suas ideias em realidade. Fale conosco!
          </p>
          <div className={styles.contactGrid}>
            <a 
              href={whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className={styles.contactCard}
            >
              <div className={styles.contactIcon}>
                <MessageCircle size={48} strokeWidth={1.5} />
              </div>
              <h3 className={styles.contactTitle}>WhatsApp</h3>
              <p className={styles.contactInfo}>(65) 98133-8458</p>
              <span className={styles.contactLink}>
                Clique para conversar 
                <ArrowRight size={16} className={styles.arrowIcon} />
              </span>
            </a>
            <a 
              href="mailto:forjobsoftware@hotmail.com"
              className={styles.contactCard}
            >
              <div className={styles.contactIcon}>
                <Mail size={48} strokeWidth={1.5} />
              </div>
              <h3 className={styles.contactTitle}>E-mail</h3>
              <p className={styles.contactInfo}>forjobsoftware@hotmail.com</p>
              <span className={styles.contactLink}>
                Enviar e-mail 
                <ArrowRight size={16} className={styles.arrowIcon} />
              </span>
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className={styles.footer}>
        <div className={styles.container}>
          <div className={styles.footerContent}>
            <div className={styles.footerLogo}>
              <img
                src="/imagens/logo.svg"
                alt="4JobSoftware Logo"
                width={100}
                height={33}
                className={styles.logo}
              />
            </div>
            <p className={styles.footerText}>
              © 2025 4JobSoftware. Todos os direitos reservados.
            </p>
            <div className={styles.footerLinks}>
              <a href="#servicos">Serviços</a>
              <a href="#contato">Contato</a>
              <a href={whatsappUrl} target="_blank" rel="noopener noreferrer">
                WhatsApp
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}

