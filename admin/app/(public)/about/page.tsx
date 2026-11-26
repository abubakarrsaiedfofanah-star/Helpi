import Image from 'next/image';
import styles from '../public-site.module.css';

export const metadata = {
  title: 'About Helpi | Community support',
  description: 'Learn about Helpi and how it brings helpers and people seeking support together.',
};

export default function AboutPage() {
  return (
    <div className={styles.informationPage}>
      <section className={styles.informationHero}>
        <div>
          <p className={styles.eyebrow}>ABOUT HELPI</p>
          <h1>Support works better when people can find each other.</h1>
          <p>Helpi is a community support app for people seeking help, people ready to help, and organizations serving their communities.</p>
          <a className={styles.primaryButton} href="/community/">Join the community</a>
        </div>
        <Image src="/helpi-community.svg" alt="Community members sharing support" width={560} height={460} priority unoptimized />
      </section>

      <section className={styles.missionSection}>
        <p className={styles.eyebrow}>WHY HELPI EXISTS</p>
        <h2>Make it easier to turn care into connection.</h2>
        <p>People want to help one another, but finding the right request, helper, or organization can be difficult. Helpi gives the community one place to discover needs, offer support, and stay connected.</p>
      </section>

      <section className={styles.valuesGrid} aria-label="Helpi principles">
        <article><span>01</span><h3>People first</h3><p>Every request and offer of help begins with the people and communities involved.</p></article>
        <article><span>02</span><h3>Support together</h3><p>Helpers and people seeking support use one shared community app.</p></article>
        <article><span>03</span><h3>Built for connection</h3><p>Helpi helps people find a next step and keep the conversation moving.</p></article>
      </section>
    </div>
  );
}
