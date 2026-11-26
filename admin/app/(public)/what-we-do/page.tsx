import styles from '../public-site.module.css';

export const metadata = {
  title: 'What Helpi does | Community support',
  description: 'Explore how Helpi helps people find support, offer help, and connect with organizations.',
};

const workAreas = [
  {
    number: '01',
    title: 'People can ask for support',
    body: 'Community members can create a request and describe the support they are looking for.',
    icon: 'heart',
  },
  {
    number: '02',
    title: 'Helpers can find ways to contribute',
    body: 'People who want to help can explore requests and connect around practical ways to support.',
    icon: 'hands',
  },
  {
    number: '03',
    title: 'Organizations can take part',
    body: 'Community organizations can join the wider support network and connect with people seeking help.',
    icon: 'community',
  },
  {
    number: '04',
    title: 'The community can stay connected',
    body: 'Messaging and updates help participants follow up as a request moves forward.',
    icon: 'chat',
  },
];

function WorkIcon({ kind }: { kind: string }) {
  const paths: Record<string, string> = {
    heart: 'M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10Z',
    hands: 'M4 12h4l3 3h3l2-2h4M6 9l3-3 3 3m-6 5-2 2 4 4 3-3m5-8 3 3-3 3',
    community: 'M16 20v-1.5a3.5 3.5 0 0 0-3.5-3.5h-5A3.5 3.5 0 0 0 4 18.5V20m14-6a3 3 0 0 1 3 3v3M10 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Zm8-1a3 3 0 1 0 0-6',
    chat: 'M20 11.5a7.5 7.5 0 0 1-8 7.5 8.8 8.8 0 0 1-3.5-.7L4 20l1.4-3.5A7 7 0 0 1 4 12c0-4.1 3.6-7.5 8-7.5s8 2.9 8 7Z',
  };
  return <svg aria-hidden="true" viewBox="0 0 24 24" fill="none"><path d={paths[kind]} stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" /></svg>;
}

export default function WhatWeDoPage() {
  return (
    <div className={styles.informationPage}>
      <section className={styles.whatHero}>
        <p className={styles.eyebrow}>WHAT WE DO</p>
        <h1>One place to ask, offer, and connect.</h1>
        <p>Helpi supports a shared community where people can find practical help and helpers can respond to real needs.</p>
      </section>
      <section className={styles.workGrid} aria-label="How Helpi supports the community">
        {workAreas.map((area) => (
          <article className={styles.workCard} key={area.number}>
            <div className={styles.workCardTop}><span className={styles.workIcon}><WorkIcon kind={area.icon} /></span><span className={styles.workNumber}>{area.number}</span></div>
            <h2>{area.title}</h2>
            <p>{area.body}</p>
          </article>
        ))}
      </section>
      <section className={styles.workCta}>
        <div><p className={styles.eyebrow}>BE PART OF IT</p><h2>Find your way to help.</h2></div>
        <a className={styles.primaryButton} href="/community/">Open the Helpi app</a>
      </section>
    </div>
  );
}
