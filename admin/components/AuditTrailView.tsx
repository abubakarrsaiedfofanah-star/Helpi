'use client';

import { useEffect, useState } from 'react';
import { adminFetch } from '../lib/api';

type AuditEvent = {
  id: string;
  action: string;
  ipAddress: string | null;
  metadata: unknown;
  createdAt: string;
  user: { name: string; email: string } | null;
};

export function AuditTrailView({ token, search }: { token: string; search: string }) {
  const [events, setEvents] = useState<AuditEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const term = search.trim().toLowerCase();
  const visible = events.filter((event) => !term || [
    event.action,
    event.ipAddress || '',
    event.user?.name || '',
    event.user?.email || '',
    JSON.stringify(event.metadata ?? ''),
  ].some((value) => value.toLowerCase().includes(term)));

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await adminFetch('/admin/audit', {}, token);
      if (!response.ok) throw new Error('Could not load administrator activity.');
      setEvents(await response.json());
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not connect to Helpi.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { void load(); }, [token]);

  return <>
    <section className="sectionHead requestHeading"><div><p className="eyebrow">ADMIN ACCOUNTABILITY</p><h1>Audit trail</h1><p>Administrator actions that change accounts or report status are recorded here.</p></div><button className="ghost" onClick={() => void load()} disabled={loading}>Refresh</button></section>
    {error && <div className="alert" role="alert">{error}</div>}{loading && <div className="inlineStatus">Loading administrator activity…</div>}
    {!loading && !error && !visible.length && <div className="emptyState"><h3>{events.length ? 'No matching activity' : 'No administrator activity yet'}</h3><p>{events.length ? 'Try another search term.' : 'Recorded actions will appear here.'}</p></div>}
    <section className="reportList">{visible.map((event) => <article className="reportCard" key={event.id}>
      <div className="reportCardHead"><span className="groupTag">{event.action.toLowerCase().replaceAll('_', ' ')}</span><span>{new Date(event.createdAt).toLocaleString()}</span></div>
      <strong>{event.user?.name || 'System'}{event.user?.email ? ` · ${event.user.email}` : ''}</strong>
      {event.metadata !== null && event.metadata !== undefined && <pre className="auditMetadata">{JSON.stringify(event.metadata, null, 2)}</pre>}
    </article>)}</section>
  </>;
}
