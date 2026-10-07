'use client';
import { useEffect, useState } from 'react';

const api = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

export function AuditTrailView() {
  const [events, setEvents] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const token = typeof window !== 'undefined' ? localStorage.getItem('helpi_admin_token') : '';

  useEffect(() => {
    fetch(`${api}/security/events`, { headers: { Authorization: `Bearer ${token || ''}` } })
      .then((r) => (r.ok ? r.json() : []))
      .then(setEvents)
      .finally(() => setLoading(false));
  }, []);

  return (
    <>
      <section className="hero compact">
        <div>
          <p className="eyebrow">SECURITY • IMMUTABLE AUDIT TRAIL</p>
          <h1>Administrative accountability.</h1>
          <p>Every administrative action, review decision, and security event is permanently recorded.</p>
        </div>
        <div className="bigNumber">⚖<small>audit log</small></div>
      </section>
      <section className="sectionHead">
        <div>
          <h2>Audit trail events</h2>
          <p>Immutable log of actions recorded across the platform.</p>
        </div>
      </section>
      <section className="workspaceGrid">
        {loading ? (
          <article className="workspaceCard"><h3>Loading audit trail…</h3></article>
        ) : events.length ? (
          events.map((e, i) => (
            <article className="workspaceCard" key={e.id || i}>
              <span className="step">LOG</span>
              <h3>{e.action}</h3>
              <p>IP: {e.ipAddress || 'hidden'} • {e.createdAt}<br />Details: {e.details ? JSON.stringify(e.details) : 'None'}</p>
            </article>
          ))
        ) : (
          <article className="workspaceCard"><h3>No audit events recorded</h3></article>
        )}
      </section>
    </>
  );
}
