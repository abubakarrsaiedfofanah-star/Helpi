import Image from 'next/image';
import styles from './page.module.css';

export const metadata = {
  title: 'Helpi | Community support',
  description: 'Get the Helpi app for Android or use the community app in your browser.',
  manifest: '/community/manifest.json',
};

export default function PublicHomePage() {
  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <a className={styles.brand} href="/" aria-label="Helpi home">
          <Image src="/helpi_logo.png" alt="" width={48} height={48} priority />
          <span>Helpi</span>
        </a>
        <a className={styles.headerLink} href="/community/">Open community app <span aria-hidden="true">?</span></a>
      </header>

      <section className={styles.hero}>
        <div className={styles.copy}>
          <p className={styles.eyebrow}>COMMUNITY SUPPORT, TOGETHER</p>
          <h1>Help connects us.</h1>
          <p className={styles.intro}>
            Helpi brings people seeking support together with helpers and community organizations.
            Choose how you want to use Helpi.
          </p>
          <div className={styles.actions}>
            <a className={styles.primary} href="/downloads/Helpi-Android.apk" download>
              <span aria-hidden="true">?</span> Download Android app
            </a>
            <a className={styles.secondary} href="/community/">
              Open the app in your browser <span aria-hidden="true">?</span>
            </a>
          </div>
          <p className={styles.note}>One community app for helpers and people who need support.</p>
        </div>
        <div className={styles.art} aria-hidden="true">
          <div className={styles.orbit}><Image src="/helpi_logo.png" alt="" width={130} height={130} priority /></div>
          <span className={styles.sparkle}>?</span>
          <span className={styles.heart}>?</span>
        </div>
      </section>

      <section className={styles.options} aria-label="Ways to use Helpi">
        <article className={styles.option}>
          <span className={styles.optionIcon} aria-hidden="true">?</span>
          <div><h2>Use it online</h2><p>Open the community app on your phone or computer. You can install it from your browser as a PWA.</p></div>
          <a href="/community/" aria-label="Open Helpi community app">?</a>
        </article>
        <article className={styles.option}>
          <span className={styles.optionIcon} aria-hidden="true">?</span>
          <div><h2>Install on Android</h2><p>Download the APK to your phone, open it, and follow Android�s install prompts.</p></div>
          <a href="/downloads/Helpi-Android.apk" download aria-label="Download Helpi Android app">?</a>
        </article>
      </section>
      <footer className={styles.footer}>Helpi connects helpers and people seeking support.</footer>
    </main>
  );
}
