interface DashboardOverviewProps {
  d: any;
  title: string;
  error: string;
  load: () => void;
  setTab: (tab: any) => void;
  cards: [string, any, string][];
  featureCards: [string, string, string][];
}

export function DashboardOverview({ d, title, error, load, setTab, cards, featureCards }: DashboardOverviewProps) {
  return (
    <>
      {d && (d.verificationQueue > 0 || d.fraudQueue > 0 || d.openReports > 0) && (
        <div style={{ background: '#FEF3C7', border: '1px solid #F59E0B', padding: '12px 20px', margin: '16px 20px 0', borderRadius: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span><b>Action Required:</b> {d.verificationQueue} cases in verification queue, {d.fraudQueue} fraud signals, {d.openReports} open reports.</span>
          <button onClick={() => setTab('fraud')} style={{ background: '#D97706', color: '#fff', border: 0, padding: '6px 12px', borderRadius: '8px', fontWeight: 700, cursor: 'pointer' }}>Review Queue</button>
        </div>
      )}
      <section className="hero">
        <div>
          <p className="eyebrow">GLOBAL HUMANITARIAN NETWORK • SECURITY FIRST</p>
          <h1>{title}</h1>
          <p>One responsive platform for discovering verified needs, coordinating assistance, protecting people and proving impact.</p>
          <div className="heroActions">
            <button className="primary" onClick={() => setTab('discover')}>Explore verified needs</button>
            <button className="light" onClick={() => setTab('trust')}>Open Trust Center</button>
          </div>
        </div>
        <div className="shield">✓</div>
      </section>
      {error && <div className="alert">{error}</div>}
      <section className="sectionHead">
        <div>
          <h2>Platform pulse</h2>
          <p>Live counts from the connected database. No fabricated operational totals.</p>
        </div>
        <button className="ghost" onClick={load}>Refresh</button>
      </section>
      <section className="grid">
        {cards.map(([k, v, s]) => (
          <article className="metric" key={String(k)}>
            <span>{k}</span>
            <b>{v ?? '—'}</b>
            <small>{s}</small>
          </article>
        ))}
      </section>
      <section className="featureGrid">
        {featureCards.map(([k, p, t]) => (
          <button className="feature" key={k} onClick={() => setTab(t)}>
            <span className="featureIcon">{k === 'Verified Help' ? '✓' : k === 'Trust Passport' ? '◈' : k === 'Proof of Impact' ? '♥' : k === 'Organization Network' ? '▣' : k === 'Global Help' ? '◎' : '♧'}</span>
            <div>
              <b>{k}</b>
              <p>{p}</p>
            </div>
            <span className="arrow">→</span>
          </button>
        ))}
      </section>
      <section className="panels">
        <article>
          <div className="cardHead">
            <h2>Security guardrails</h2>
            <span className="ok">ACTIVE</span>
          </div>
          <ul>
            <li><b>Private evidence</b><span>Short-lived access links and ownership checks.</span></li>
            <li><b>Human review</b><span>Fraud and safeguarding signals are investigation leads, not verdicts.</span></li>
            <li><b>Payment controls</b><span>Country-aware provider routing and signed webhooks.</span></li>
            <li><b>Auditability</b><span>Administrative actions are recorded for accountability.</span></li>
          </ul>
        </article>
        <article>
          <div className="cardHead">
            <h2>Trust layers</h2>
            <span className="ok">MULTI-LAYERED</span>
          </div>
          {['Identity', 'Need', 'Institution', 'Payment destination', 'Independent evidence', 'Recent review'].map((x) => (
            <div className="status" key={x}>
              <span className="dot" />
              <b>{x}</b>
              <span>Specific verification</span>
            </div>
          ))}
        </article>
      </section>
    </>
  );
}
