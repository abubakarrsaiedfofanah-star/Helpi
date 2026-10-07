'use client';
import { useEffect, useState } from 'react';

const api = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

export function MediaReviewView() {
  const [items, setItems] = useState<any[]>([]);
  const [msg, setMsg] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const token = typeof window !== 'undefined' ? localStorage.getItem('helpi_admin_token') : '';

  const load = () => {
    setLoading(true);
    return fetch(`${api}/admin/media-review`, { headers: { Authorization: `Bearer ${token || ''}` } })
      .then((r) => {
        if (!r.ok) throw new Error('Could not load the review queue.');
        return r.json();
      })
      .then(setItems)
      .catch((e) => setMsg(e.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const review = async (id: string, status: 'APPROVED' | 'BLOCKED') => {
    setBusyId(id);
    try {
      await fetch(`${api}/admin/media/${id}/review`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token || ''}` },
        body: JSON.stringify({ status, reason: status === 'BLOCKED' ? 'Blocked by human privacy/safety review' : 'Approved after human review' }),
      });
      load();
    } finally {
      setBusyId(null);
    }
  };

  return (
    <>
      <section className="hero compact">
        <div>
          <p className="eyebrow">MEDIA • PRIVACY • SAFEGUARDING</p>
          <h1>Review before public playback.</h1>
          <p>Uploaded videos stay private until an authorized reviewer explicitly approves them.</p>
        </div>
        <div className="bigNumber">▶<small>human review</small></div>
      </section>
      <section className="sectionHead">
        <div>
          <h2>Video evidence queue</h2>
          <p>Do not approve media containing unnecessary personal data, private addresses, payment credentials or unsafe exposure of children.</p>
        </div>
        <button className="ghost" onClick={load}>Refresh</button>
      </section>
      {msg && <div className="alert">{msg}</div>}
      <section className="workspaceGrid">
        {loading ? (
          <article className="workspaceCard">
            <h3>Loading review queue…</h3>
            <p>Fetching private media that needs human review.</p>
          </article>
        ) : items.length ? (
          items.map((x) => (
            <article className="workspaceCard" key={x.id}>
              <span className="step">VIDEO</span>
              <h3>{x.case?.title || 'Case evidence'}</h3>
              <p>{x.mimeType} • {x.case?.countryCode || ''}<br />Status: {x.moderationStatus}</p>
              <div style={{ display: 'flex', gap: 8 }}>
                <button className="primary" aria-busy={busyId === x.id} disabled={busyId !== null} onClick={() => review(x.id, 'APPROVED')}>
                  {busyId === x.id ? 'Saving…' : 'Approve'}
                </button>
                <button className="ghost" disabled={busyId !== null} onClick={() => review(x.id, 'BLOCKED')}>Block</button>
              </div>
            </article>
          ))
        ) : (
          <article className="workspaceCard">
            <h3>No media awaiting review</h3>
            <p>The queue is clear.</p>
          </article>
        )}
      </section>
    </>
  );
}
