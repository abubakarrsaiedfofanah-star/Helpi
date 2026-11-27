import Image from 'next/image';
import styles from '../app/(public)/public-site.module.css';

export function AboutSection() {
  return (
    <div className={styles.informationPage} id="about">
      <section className={styles.informationHero}>
        <div>
          <p className={styles.eyebrow}>ABOUT HELPI</p>
          <h1>Connecting people who need financial help with people ready to help.</h1>
          <p>Helpi is a community app that brings people seeking financial support and helpers together. It helps them discover requests and connect directly.</p>
          <a className={styles.primaryButton} href="/community/">Open the community app</a>
        </div>
        <Image className={styles.infoPhoto} src="/images/community-water-project.jpg" alt="Local volunteers working together on a community water project in Ghana" width={960} height={1440} unoptimized />
      </section>

      <section className={styles.missionSection}>
        <p className={styles.eyebrow}>WHY HELPI EXISTS</p>
        <h2>Make it easier for people to find one another.</h2>
        <p>People seeking financial help can share a request. Helpers can review requests and choose whether to connect. Helpi provides a shared place for that connection; people decide together what help to offer.</p>
      </section>

      <section className={styles.valuesGrid} aria-label="How Helpi connects people">
        <article><span>01</span><h3>Share a request</h3><p>People can explain the financial support they are seeking.</p></article>
        <article><span>02</span><h3>Find a helper</h3><p>Helpers can discover requests and decide which people to contact.</p></article>
        <article><span>03</span><h3>Connect directly</h3><p>People use the Helpi community app to communicate about a request.</p></article>
      </section>
    </div>
  );
}

const workAreas = [
  { number: '01', title: 'People request financial help', body: 'A person shares a request describing the financial support they need.', icon: 'heart' },
  { number: '02', title: 'Helpers discover requests', body: 'Helpers browse requests and choose whether they want to connect with someone.', icon: 'hands' },
  { number: '03', title: 'People connect directly', body: 'The person seeking support and a helper can continue their conversation in Helpi.', icon: 'community' },
];

function WorkIcon({ kind }: { kind: string }) {
  const paths: Record<string, string> = {
    heart: 'M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10Z',
    hands: 'M4 12h4l3 3h3l2-2h4M6 9l3-3 3 3m-6 5-2 2 4 4 3-3m5-8 3 3-3 3',
    community: 'M16 20v-1.5a3.5 3.5 0 0 0-3.5-3.5h-5A3.5 3.5 0 0 0 4 18.5V20m14-6a3 3 0 0 1 3 3v3M10 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Zm8-1a3 3 0 1 0 0-6',
  };
  return <svg aria-hidden="true" viewBox="0 0 24 24" fill="none"><path d={paths[kind]} stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" /></svg>;
}

export function WhatWeDoSection() {
  return (
    <div className={styles.informationPage} id="what-we-do">
      <section className={styles.whatHero}>
        <p className={styles.eyebrow}>WHAT WE DO</p>
        <h1>We connect people seeking financial help with helpers.</h1>
        <p>Helpi gives people one place to share financial requests, find helpers, and connect directly. Helpi is a connection platform; it does not promise or guarantee financial assistance.</p>
      </section>
      <section className={styles.workGrid} aria-label="How Helpi connects people">
        {workAreas.map((area) => (
          <article className={styles.workCard} key={area.number}>
            <div className={styles.workCardTop}><span className={styles.workIcon}><WorkIcon kind={area.icon} /></span><span className={styles.workNumber}>{area.number}</span></div>
            <h2>{area.title}</h2>
            <p>{area.body}</p>
          </article>
        ))}
      </section>
      <section className={styles.workCta}>
        <div><p className={styles.eyebrow}>ONE SHARED COMMUNITY</p><h2>Find a way to connect.</h2></div>
        <a className={styles.primaryButton} href="/community/">Open the Helpi app</a>
      </section>
    </div>
  );
}
