import Image from 'next/image';
import styles from '../public-site.module.css';

export const metadata = {
  title: 'Get the Helpi app',
  description: 'Download Helpi for Android or install the community app on a supported phone, tablet, or computer.',
};

export default function GetTheAppPage() {
  return (
    <div className={styles.informationPage}>
      <section className={styles.appHero}>
        <div>
          <p className={styles.eyebrow}>GET THE HELPI APP</p>
          <h1>Use Helpi on the device you have.</h1>
          <p>Install the Android app, or open the community app in your browser and add it to your home screen where supported.</p>
          <a className={styles.primaryButton} href="/community/">Open Helpi in browser</a>
        </div>
        <Image className={styles.infoPhoto} src="/images/volunteers-accra.jpg" alt="Community volunteers sharing food in Accra" width={1280} height={853} priority />
      </section>

      <section className={styles.deviceGrid} aria-label="Install Helpi on your device">
        <article className={styles.deviceCard}>
          <div className={styles.deviceHeading}><span>ANDROID</span><span className={styles.deviceBadge}>APK</span></div>
          <h2>Install on Android</h2>
          <p>Download the Helpi APK, open it from your phone's downloads, and follow Android's install prompts.</p>
          <a className={styles.primaryButton} href="/downloads/Helpi-Android.apk" download>Download Android app</a>
          <small>Android may ask you to allow installation from your browser.</small>
        </article>
        <article className={styles.deviceCard} id="install-on-iphone">
          <div className={styles.deviceHeading}><span>IPHONE OR IPAD</span><span className={styles.deviceBadge}>PWA</span></div>
          <h2>Add Helpi to your home screen</h2>
          <p>Open Helpi in Safari, tap Share, then choose Add to Home Screen.</p>
          <a className={styles.secondaryButton} href="/community/">Open the community app</a>
          <small>The web app works in your browser; no APK is needed on Apple devices.</small>
        </article>
        <article className={styles.deviceCard}>
          <div className={styles.deviceHeading}><span>TABLET OR COMPUTER</span><span className={styles.deviceBadge}>WEB</span></div>
          <h2>Use Helpi online</h2>
          <p>Open the community app in a browser. On supported browsers, use Install app or Add to Home Screen.</p>
          <a className={styles.secondaryButton} href="/community/">Open Helpi</a>
          <small>Your browser will show the install option when it supports it.</small>
        </article>
      </section>
    </div>
  );
}
