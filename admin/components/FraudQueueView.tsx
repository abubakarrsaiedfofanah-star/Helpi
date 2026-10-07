'use client';
import { useEffect, useState } from 'react';

const api = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

export function FraudQueueView() {
  const [signals, setSignals] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const token = typeof window !== 'undefined' ? localStorage.getItem('helpi_admin_token') : '';

  useEffect(() => {
    fetch(`${api}/fraud`, { headers: { Authorization: `Bearer ${token || ''}` } })
      .then((r) => (r.ok ? r.json() : []))
      .then(setSignals)
      .finally(() => setLoading(false));
  }, []);

  return (
    <>
      <section className="hero compact">
        <div>
          <p className="eyebrow">FRAUD • RISK ENGINE • INVESTIGATION</p>
          <h1>Risk signal investigations.</h1>
          <p>Analyze duplicate descriptions, thin evidence, and high-value risk signals with authorized human review.</p>
        </div>
        <div className="bigNumber">⚡<small>risk signals</small></div>
      </section>
      <section className="sectionHead">
        <div>
          <h2>Active fraud signals</h2>
          <p>Investigation leads — not automatic guilt verdicts.</p>
        </div>
      </section>
      <section className="workspaceGrid">
        {loading ? (
          <article className="workspaceCard"><h3>Loading fraud queue…</h3></article>
        ) : signals.length ? (
          signals.map((s, i) => (
            <article className="workspaceCard" key={s.id || i}>
              <span className="step">RISK</span>
              <h3>Signal: {s.signalType || 'Risk indicator'}</h3>
              <p>Severity: <b>{s.severity || 'MEDIUM'}</b><br />{s.description || 'Investigation required.'}</p>
            </article>
          ))
        ) : (
          <article className="workspaceCard">
            <h3>No active fraud signals</h3>
            <p>The fraud queue is currently clear.</p>
          </article>
        )}
      </section>
    </>
  );
}
