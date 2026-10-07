type Tab = 'overview' | 'discover' | 'trust' | 'impact' | 'organizations' | 'countries' | 'circles' | 'security' | 'media' | 'global' | 'audit' | 'fraud';

interface GenericWorkspaceViewProps {
  tab: Tab;
  d: any;
  search: string;
}

export function GenericWorkspaceView({ tab, d, search }: GenericWorkspaceViewProps) {
  const data: { [key: string]: { eyebrow: string; items: string[]; cta: string } } = {
    discover: { eyebrow: 'DISCOVER • VERIFY • HELP', items: ['Verified medical support', 'Education and school fees', 'Food and family support', 'Water and sanitation projects', 'Housing and emergency shelter', 'Community infrastructure'], cta: 'Open discovery' },
    trust: { eyebrow: 'TRUST • SAFETY • REVIEW', items: ['Identity verification', 'Need verification', 'Institution confirmation', 'Payment destination checks', 'Document/OCR review', 'Independent evidence and recent review'], cta: 'Open verification queue' },
    impact: { eyebrow: 'IMPACT • TRANSPARENCY', items: ['Contribution timeline', 'Receipts and confirmations', 'Before / during / after updates', 'Institution impact reports', 'Aggregate global impact map', 'Personal impact profile'], cta: 'Open impact workspace' },
    organizations: { eyebrow: 'ORGANIZATIONS • NETWORK', items: ['Schools', 'Hospitals and clinics', 'NGOs', 'Community groups', 'Faith and community institutions', 'Authorized staff accounts'], cta: 'Open organization workspace' },
    countries: { eyebrow: 'COUNTRIES • LOCAL CONTEXT', items: ['Country-aware currencies', 'Local payment routes', 'Local verification requirements', 'Languages and accessibility', 'Emergency resources', 'Country impact pages'], cta: 'Open country explorer' },
    circles: { eyebrow: 'HELP CIRCLES • COMMUNITY', items: ['Private family circles', 'Shared goals', 'Contribution tracking', 'Group updates', 'Role-based circle permissions', 'Completion and impact history'], cta: 'Create a Help Circle' },
    global: { eyebrow: 'GLOBAL OPERATIONS • LOCAL CONTEXT', items: ['Country and currency registry', 'Language and translation coverage', 'Accessibility standards', 'Low-data and offline readiness', 'Country-specific payment routes', 'Local verification and safeguarding rules', 'Emergency-resource directory', 'Regional operational policies'], cta: 'Open global operations' },
    security: { eyebrow: 'SECURITY • OPERATIONS', items: ['Account protection and MFA', 'Active sessions', 'Fraud graph investigations', 'Safeguarding cases', 'Sanctions screening', 'Immutable audit trail'], cta: 'Open security operations' }
  };
  const x = data[tab];
  if (!x) return null;

  return (
    <>
      <section className="hero compact">
        <div>
          <p className="eyebrow">{x.eyebrow}</p>
          <h1>
            {({
              discover: 'Verified help, not noise.',
              trust: 'Trust you can understand.',
              impact: 'Every contribution should tell a story.',
              organizations: 'One network for trusted organizations.',
              countries: 'Global reach, local reality.',
              circles: 'Help together, safely.',
              global: 'Global by design. Local where it matters.',
              security: 'Security is part of the product.'
            } as any)[tab]}
          </h1>
          <p>Responsive workflows are designed around privacy, human review, accessibility and clear next actions.</p>
          <button className="primary">{x.cta}</button>
        </div>
        <div className="bigNumber">{tab === 'security' ? '24/7' : '∞'}<small>{tab === 'security' ? 'monitoring mindset' : 'possibilities to help'}</small></div>
      </section>
      <section className="sectionHead">
        <div>
          <h2>{tab[0].toUpperCase() + tab.slice(1)} workspace</h2>
          <p>{search ? `Filtering around “${search}”.` : 'Choose a workflow to continue.'}</p>
        </div>
      </section>
      <section className="workspaceGrid">
        {x.items.map((item, i) => (
          <article className="workspaceCard" key={item}>
            <span className="step">{String(i + 1).padStart(2, '0')}</span>
            <h3>{item}</h3>
            <p>{tab === 'trust' ? 'Specific evidence is reviewed against the appropriate requirement.' : tab === 'impact' ? 'Keep the journey from assistance to confirmed outcome visible.' : tab === 'security' ? 'Protected by authentication, authorization, rate limits and audit controls.' : 'Built to be useful on phone, tablet and desktop.'}</p>
            <button className="ghost">Open →</button>
          </article>
        ))}
      </section>
      {tab === 'countries' && <div className="countryBand"><b>Country-aware by design</b><span>Store original transaction currency, display currency separately, and never expose a vulnerable person’s exact address publicly.</span></div>}
      {tab === 'security' && (
        <section className="securityMatrix">
          <article>
            <h2>Security posture</h2>
            <div className="securityRows">
              {['Authentication', 'Authorization', 'Sensitive evidence', 'Fraud detection', 'Safeguarding', 'Payments', 'Audit logging'].map((x, i) => (
                <div key={x}>
                  <b>{x}</b>
                  <span className="secureStatus">{i === 4 ? 'Human escalation' : 'Protected'}</span>
                </div>
              ))}
            </div>
          </article>
          <article>
            <h2>Incident response</h2>
            <p>Security events can be contained, investigated, escalated and audited without automatically labeling a person guilty.</p>
            <button className="primary">Open incident workflow</button>
          </article>
        </section>
      )}
    </>
  );
}
