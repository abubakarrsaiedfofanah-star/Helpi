import Image from 'next/image';
import styles from './public-site.module.css';
import { DeviceAppLink } from '../../components/DeviceAppLink';
import { AboutSection, WhatWeDoSection } from '../../components/PublicSiteSections';

export const metadata = {
  title: 'Helpi | Connect for financial help',
  description: 'Helpi connects people seeking financial help with helpers who choose to connect.',
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
    <>
      <section className={styles.hero} id="home">
        <div className={styles.heroCopy}>
          <p className={styles.eyebrow}><span /> COMMUNITY SUPPORT, TOGETHER</p>
          <h1>Help feels closer when we connect.</h1>
          <p className={styles.lede}>
            Helpi connects people seeking financial help with helpers who want to connect.
          </p>
          <div className={styles.heroActions}>
            <DeviceAppLink className={styles.primaryButton}>
              <DownloadIcon /> Get the app
            </DeviceAppLink>
            <a className={styles.secondaryButton} href="/community/">
              Open the web app <ArrowIcon />
            </a>
          </div>
          <div className={styles.heroMeta}>
            <span className={styles.metaIcon} aria-hidden="true">H</span>
          <span>For people seeking financial help and the helpers who connect with them</span>
          </div>
        </div>

        <div className={styles.heroVisual}>
          <Image
            className={styles.heroPhoto}
            src="/images/volunteers-accra.jpg"
            alt="Community volunteers sharing food with people in Accra"
            width={1280}
            height={853}
            priority
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
          <p>One shared app connects people seeking financial help with helpers.</p>
        </div>
        <div className={styles.audienceGrid}>
          <article className={styles.audienceCard}>
            <span className={`${styles.audienceIcon} ${styles.supportIcon}`} aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none"><path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10Z" stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round" /></svg>
            </span>
            <h3>Looking for support?</h3>
            <p>Browse financial help requests and connect with a helper.</p>
            <a href="/community/">Find support <ArrowIcon /></a>
          </article>
          <article className={styles.audienceCard}>
            <span className={`${styles.audienceIcon} ${styles.helpIcon}`} aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none"><path d="M12 3v18M3 12h18M5.6 5.6l12.8 12.8m0-12.8L5.6 18.4" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" /></svg>
            </span>
            <h3>Ready to help?</h3>
            <p>Review requests from people seeking financial help and choose whether to connect.</p>
            <a href="/community/">Offer help <ArrowIcon /></a>
          </article>
        </div>
      </section>

      <AboutSection />
      <WhatWeDoSection />

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

      <section className={styles.communityStory} aria-labelledby="community-story-title">
        <Image
          className={styles.storyPhoto}
          src="/images/community-water-project.jpg"
          alt="Volunteers and nearby residents working together to repair a community water borehole in Ghana"
          width={960}
          height={1440}
        />
        <div className={styles.storyCopy}>
          <p className={styles.eyebrow}>COMMUNITY IN ACTION</p>
          <h2 id="community-story-title">Support grows when people work together.</h2>
          <p>This photo shows neighbors working together on a local water project in Ghana. Helpi focuses on connecting people seeking financial help with helpers.</p>
          <a className={styles.storyLink} href="/what-we-do/">See what Helpi does <ArrowIcon /></a>
        </div>
      </section>

      <section className={styles.downloadSection} id="get-the-app">
        <div>
          <p className={styles.eyebrow}>HELPI GOES WITH YOU</p>
          <h2>Choose how you want to use Helpi.</h2>
          <p>Open the community app in your browser or install the Android app on your phone.</p>
        </div>
        <div className={styles.downloadActions}>
          <DeviceAppLink className={styles.downloadButton}><DownloadIcon /> Get the app</DeviceAppLink>
          <a className={styles.webButton} href="/community/">Use Helpi online <ArrowIcon /></a>
        </div>
      </section>

    </>
  );
}
