interface DashboardOverviewProps {
  d: any;
  title: string;
  error: string;
  load: () => void;
  setTab: (tab: any) => void;
  cards: [string, number | undefined, string][];
  featureCards: [string, string, any][];
}

const groupLabels: Record<string, string> = {
  ORPHAN: 'Orphans', WIDOW: 'Widows', WAR_SURVIVOR: 'War survivors',
  DISABILITY: 'People with disabilities', ELDERLY: 'Older adults',
  DISPLACED_PERSON: 'Refugees and displaced people', SINGLE_PARENT: 'Single parents',
  UNEMPLOYED: 'Unemployed people', LOW_INCOME_FAMILY: 'Low-income families',
  CAREGIVER: 'Caregivers', CHRONIC_ILLNESS: 'People with chronic illness',
  HOMELESS: 'People without stable housing', TRAFFICKING_SURVIVOR: 'Survivors of trafficking or abuse',
  OTHER: 'Other groups',
};

export function DashboardOverview({ d, title, error, load, setTab, cards, featureCards }: DashboardOverviewProps) {
  const groups = (d?.requestGroups || []) as { category: string; _count: { _all: number } }[];
  const maxCount = Math.max(1, ...groups.map((group) => group._count._all));

  return <>
    <section className="hero">
      <div><p className="eyebrow">HELPI COMMUNITY</p><h1>{title}</h1><p>Keep the community organized so people can connect directly with helpers and NGOs.</p><div className="heroActions"><button className="primary" onClick={() => setTab('requests')}>View requests</button><button className="light" onClick={() => setTab('people')}>Manage people</button></div></div>
      <div className="shield" aria-hidden="true">H</div>
    </section>
    {error && <div className="alert" role="alert">{error}</div>}
    <section className="sectionHead"><div><h2>Community overview</h2><p>Live counts from the Helpi database.</p></div><button className="ghost" onClick={load}>Refresh</button></section>
    <section className="grid">{cards.map(([label, value, note]) => <article className="metric" key={label}><span>{label}</span><b>{value ?? '-'}</b><small>{note}</small></article>)}</section>
    <section className="panels">
      <article><div className="cardHead"><div><h2>Requests by group</h2><p className="muted">Requests show a support group and amount.</p></div><button className="ghost" onClick={() => setTab('requests')}>View list</button></div>
        {groups.length ? groups.map((group) => <div className="groupBar" key={group.category}><div><b>{groupLabels[group.category] || group.category}</b><span>{group._count._all}</span></div><div className="barTrack"><i style={{ width: `${Math.max(5, group._count._all / maxCount * 100)}%` }} /></div></div>) : <div className="emptyState"><h3>No published requests yet</h3><p>Requests will appear here when people post them.</p></div>}
      </article>
      <article><div className="cardHead"><h2>Admin workspaces</h2><span className="ok">READY</span></div><div className="adminQuickLinks">{featureCards.map(([label, description, target]) => <button key={label} className="quickLink" onClick={() => setTab(target)}><span className="featureIcon" aria-hidden="true">{label === 'Support requests' ? 'R' : label === 'Organizations' ? 'O' : label === 'Community safety' ? '!' : 'P'}</span><span><b>{label}</b><small>{description}</small></span><span className="arrow" aria-hidden="true">&gt;</span></button>)}</div></article>
    </section>
  </>;
}
