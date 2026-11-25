'use client';

import { useEffect, useState } from 'react';
import { adminFetch } from '../lib/api';

type Organization = { id: string; name: string; type: string; countryCode: string; city: string | null; description: string | null; website: string | null; createdAt: string };

export function OrganizationsView({ token, search }: { token: string; search: string }) {
  const [items, setItems] = useState<Organization[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await adminFetch('/admin/organizations', {}, token);
      if (!response.ok) throw new Error('Could not load organizations.');
      setItems(await response.json());
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not connect to Helpi.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { void load(); }, [token]);

  const term = search.trim().toLowerCase();
  const visible = items.filter((item) => !term || [item.name, item.type, item.countryCode, item.city || ''].some((value) => value.toLowerCase().includes(term)));
  return <>
    <section className="sectionHead requestHeading"><div><p className="eyebrow">COMMUNITY PARTNERS</p><h1>Organizations</h1><p>NGOs and community organizations connected to people seeking support.</p></div><button className="ghost" onClick={() => void load()} disabled={loading}>Refresh</button></section>
    {error && <div className="alert" role="alert">{error}</div>}{loading && <div className="inlineStatus">Loading organizations…</div>}
    {!loading && !error && !visible.length && <div className="emptyState"><h3>No organizations found</h3><p>Registered community partners will appear here.</p></div>}
    <section className="requestGrid">{visible.map((item) => <article className="requestCard" key={item.id}><div className="requestCardTop"><span className="groupTag">{item.type}</span><span>{item.countryCode}{item.city ? ` · ${item.city}` : ''}</span></div><h2>{item.name}</h2>{item.description && <p className="organizationDescription">{item.description}</p>}{item.website && <a href={item.website} target="_blank" rel="noreferrer">Visit organization</a>}<small>Joined {new Date(item.createdAt).toLocaleDateString()}</small></article>)}</section>
  </>;
}
