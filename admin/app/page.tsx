import Image from 'next/image';
import styles from './page.module.css';

export const metadata = {
  title: 'Helpi | Community support',
  description: 'Find community support or offer help with the Helpi app.',
  manifest: '/community/manifest.json',
};

function ArrowIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none">
      <path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function DownloadIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none">
      <path d="M12 3v12m0 0 4-4m-4 4-4-4M5 17v3h14v-3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function PublicHomePage() {
  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <a className={styles.brand} href="/" aria-label="Helpi home">
          <Image src="/helpi_logo.png" alt="" width={46} height={46} priority />
          <span>Helpi</span>
        </a>
        <nav className={styles.nav} aria-label="Main navigation">
          <a href="#how-it-works">How it works</a>
          <a href="/community/">Community app</a>
        </nav>
        <a className={styles.headerCta} href="#get-the-app">Get the app <ArrowIcon /></a>
      </header>

      <section className={styles.hero}>
        <div className={styles.heroCopy}>
          <p className={styles.eyebrow}><span /> COMMUNITY SUPPORT, TOGETHER</p>
          <h1>Help feels closer when we connect.</h1>
          <p className={styles.lede}>
            Helpi brings people seeking support together with helpers and community organizations.
            Find a way to give or receive support in one welcoming app.
          </p>
          <div className={styles.heroActions}>
            <a className={styles.primaryButton} href="/downloads/Helpi-Android.apk" download>
              <DownloadIcon /> Download for Android
            </a>
            <a className={styles.secondaryButton} href="/community/">
              Open the web app <ArrowIcon />
            </a>
          </div>
          <div className={styles.heroMeta}>
            <span className={styles.metaIcon} aria-hidden="true">H</span>
            <span>For helpers and people looking for support</span>
          </div>
        </div>

        <div className={styles.heroVisual}>
          <div className={styles.visualGlow} />
          <Image
            className={styles.illustration}
            src="/helpi-community.svg"
            alt="Illustration of community members sharing support"
            width={680}
            height={560}
            priority
            unoptimized
          />
          <div className={styles.floatingNote}>
            <span className={styles.noteHeart} aria-hidden="true">+</span>
            <span><strong>Small acts matter</strong><small>Support starts with people</small></span>
          </div>
        </div>
      </section>

      <section className={styles.audience} aria-label="Who Helpi is for">
        <div className={styles.sectionIntro}>
          <p className={styles.eyebrow}>ONE COMMUNITY APP</p>
          <h2>There is a place for you here.</h2>
          <p>Whether you need a hand or are ready to lend one, start in the same community.</p>
        </div>
        <div className={styles.audienceGrid}>
          <article className={styles.audienceCard}>
            <span className={`${styles.audienceIcon} ${styles.supportIcon}`} aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none"><path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10Z" stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round" /></svg>
            </span>
            <h3>Looking for support?</h3>
            <p>Explore community requests and connect with people and organizations offering help.</p>
            <a href="/community/">Find support <ArrowIcon /></a>
          </article>
          <article className={styles.audienceCard}>
            <span className={`${styles.audienceIcon} ${styles.helpIcon}`} aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none"><path d="M12 3v18M3 12h18M5.6 5.6l12.8 12.8m0-12.8L5.6 18.4" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" /></svg>
            </span>
            <h3>Ready to help?</h3>
            <p>Find requests where your time, skills, or contribution could make a difference.</p>
            <a href="/community/">Offer help <ArrowIcon /></a>
          </article>
        </div>
      </section>

      <section className={styles.howSection} id="how-it-works">
        <div className={styles.howHeading}>
          <p className={styles.eyebrow}>GET STARTED</p>
          <h2>A simple way to show up.</h2>
        </div>
        <div className={styles.steps}>
          <article><span>01</span><h3>Join the community</h3><p>Create an account in the app and tell us a little about yourself.</p></article>
          <article><span>02</span><h3>Explore ways to connect</h3><p>Browse support requests or see where your help may be useful.</p></article>
          <article><span>03</span><h3>Take the next step</h3><p>Connect through Helpi and keep your support journey in one place.</p></article>
        </div>
      </section>

      <section className={styles.downloadSection} id="get-the-app">
        <div>
          <p className={styles.eyebrow}>HELPI GOES WITH YOU</p>
          <h2>Choose how you want to use Helpi.</h2>
          <p>Open the community app in your browser or install the Android app on your phone.</p>
        </div>
        <div className={styles.downloadActions}>
          <a className={styles.downloadButton} href="/downloads/Helpi-Android.apk" download><DownloadIcon /> Download Android app</a>
          <a className={styles.webButton} href="/community/">Use Helpi online <ArrowIcon /></a>
        </div>
      </section>

      <footer className={styles.footer}>
        <div className={styles.footerMain}>
          <a className={styles.brand} href="/" aria-label="Helpi home">
            <Image src="/helpi_logo.png" alt="" width={42} height={42} />
            <span>Helpi</span>
          </a>
          <p>Bringing helpers and people seeking support closer together.</p>
        </div>
        <nav className={styles.footerLinks} aria-label="Footer navigation">
          <a href="/community/">Open community app</a>
          <a href="/downloads/Helpi-Android.apk" download>Download Android app</a>
        </nav>
        <div className={styles.footerBottom}>
          <span>Community support, together.</span>
          <span>Helpi</span>
        </div>
      </footer>
    </main>
  );
}
