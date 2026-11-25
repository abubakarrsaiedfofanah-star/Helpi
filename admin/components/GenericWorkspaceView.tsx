type Tab = 'organizations' | 'countries' | 'safety' | 'security';

const workspace: Record<Tab, { eyebrow: string; title: string; description: string; items: string[] }> = {
  organizations: {
    eyebrow: 'COMMUNITY PARTNERS',
    title: 'Organizations',
    description: 'A directory for NGOs and community organizations who want to connect with people seeking support.',
    items: ['NGO profiles', 'Community organizations', 'Organization contacts', 'Country and language coverage'],
  },
  countries: {
    eyebrow: 'LOCAL SETTINGS',
    title: 'Countries',
    description: 'Keep local language and currency information clear for people posting or browsing requests.',
    items: ['Country availability', 'Local currency display', 'Languages', 'Regional support contacts'],
  },
  safety: {
    eyebrow: 'COMMUNITY SAFETY',
    title: 'Reports and safeguarding',
    description: 'Review user reports and safeguarding concerns to help keep direct contact respectful and safe.',
    items: ['Open user reports', 'Safeguarding cases', 'Urgent follow-up', 'Community safety guidance'],
  },
  security: {
    eyebrow: 'ACCOUNT SECURITY',
    title: 'Security',
    description: 'Keep administrator access and community accounts protected.',
    items: ['Administrator sign-in', 'Two-factor authentication', 'Account sessions', 'Audit history'],
  },
};

export function GenericWorkspaceView({ tab }: { tab: Tab; d?: any; search?: string }) {
  const current = workspace[tab];
  return (
    <>
      <section className="hero compact">
        <div><p className="eyebrow">{current.eyebrow}</p><h1>{current.title}</h1><p>{current.description}</p></div>
        <div className="bigNumber" aria-hidden="true">H</div>
      </section>
      <section className="sectionHead"><div><h2>{current.title} workspace</h2><p>Tools for Helpi administrators.</p></div></section>
      <section className="workspaceGrid">
        {current.items.map((item, index) => (
          <article className="workspaceCard" key={item}>
            <span className="step">{String(index + 1).padStart(2, '0')}</span>
            <h3>{item}</h3>
            <p>Manage this area from the connected admin workspace.</p>
          </article>
        ))}
      </section>
    </>
  );
}
