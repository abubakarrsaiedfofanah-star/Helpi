import Image from 'next/image';
import styles from '../app/(public)/public-site.module.css';
import { PublicSiteNav } from './PublicSiteNav';

function Arrow() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>;
}

export function PublicSiteChrome({ children }: { children: React.ReactNode }) {
  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <a className={styles.brand} href="/" aria-label="Helpi home">
          <Image src="/helpi_logo.png" alt="" width={46} height={46} priority unoptimized />
          <span>Helpi</span>
        </a>
        <PublicSiteNav />
        <a className={styles.headerCta} href="/get-the-app/">Get the app <Arrow /></a>
      </header>
      <main>{children}</main>
      <footer className={styles.footer}>
        <div className={styles.footerMain}>
          <a className={styles.brand} href="/" aria-label="Helpi home">
            <Image src="/helpi_logo.png" alt="" width={42} height={42} unoptimized />
            <span>Helpi</span>
          </a>
          <p>Connecting people seeking financial help with helpers.</p>
        </div>
        <nav className={styles.footerLinks} aria-label="Footer navigation">
          <a href="/#home">Home</a>
          <a href="/about/">About us</a>
          <a href="/what-we-do/">What we do</a>
          <a href="/get-the-app/">Get the app</a>
          <a href="/community/">Open community app</a>
        </nav>
        <div className={styles.footerBottom}>
          <span>Financial help, connected.</span>
          <span>Photos: <a href="https://commons.wikimedia.org/wiki/File:Free_Food_distribution.jpg" target="_blank" rel="noreferrer">Esthee2010</a> and <a href="https://commons.wikimedia.org/wiki/File:Workers_and_Volunteers_helping_out.jpg" target="_blank" rel="noreferrer">Rebecamarta</a> · <a href="https://creativecommons.org/licenses/by-sa/4.0/" target="_blank" rel="noreferrer">CC BY-SA 4.0</a></span>
        </div>
      </footer>
    </div>
  );
}
