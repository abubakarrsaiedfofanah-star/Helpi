'use client';

import { useEffect, useState } from 'react';
import { adminFetch } from '../lib/api';

type Report = {
  id: string;
  type: string;
  status: string;
  description: string;
  createdAt: string;
  reporter: { name: string };
  case?: { category: string; countryCode: string } | null;
};

export function SafetyReportsView({ token, search }: { token: string; search: string }) {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState('');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const term = search.trim().toLowerCase();
  const visible = reports.filter((report) => !term || [
    report.type,
    report.status,
    report.description,
    report.reporter.name,
    report.case?.category || '',
    report.case?.countryCode || '',
  ].some((value) => value.toLowerCase().includes(term)));

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await adminFetch('/admin/safety-reports', {}, token);
      if (!response.ok) throw new Error('Could not load community reports.');
      setReports(await response.json());
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not connect to Helpi.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { void load(); }, [token]);

  const update = async (id: string, status: 'IN_REVIEW' | 'RESOLVED' | 'DISMISSED') => {
    setBusyId(id);
    setError('');
    setNotice('');
    try {
      const response = await adminFetch(`/admin/safety-reports/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      }, token);
      const result = await response.json();
      if (!response.ok) throw new Error(result.message || 'Could not update report.');
      setNotice(`Report marked ${status.toLowerCase().replace('_', ' ')}.`);
      await load();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not update report.');
    } finally {
      setBusyId('');
    }
  };

  return <>
    <section className="sectionHead requestHeading"><div><p className="eyebrow">COMMUNITY CARE</p><h1>Safety reports</h1><p>Review reports about conduct and help keep direct conversations respectful.</p></div><button className="ghost" onClick={() => void load()} disabled={loading}>Refresh</button></section>
    {error && <div className="alert" role="alert">{error}</div>}{notice && <div className="inlineStatus ok" role="status">{notice}</div>}
    {loading && <div className="inlineStatus">Loading reports…</div>}
    {!loading && !error && !visible.length && <div className="emptyState"><h3>{reports.length ? 'No matching reports' : 'No open reports'}</h3><p>{reports.length ? 'Try another search term.' : 'New community reports will appear here.'}</p></div>}
    <section className="reportList">{visible.map((report) => <article className="reportCard" key={report.id}>
      <div className="reportCardHead"><span className="groupTag">{report.type.toLowerCase().replace('_', ' ')}</span><span className={`statusBadge ${report.status.toLowerCase()}`}>{report.status.toLowerCase().replace('_', ' ')}</span><span>{new Date(report.createdAt).toLocaleString()}</span></div>
      <p className="reportDescription">{report.description}</p>
      <p className="muted">Reported by {report.reporter.name}{report.case ? ` · ${report.case.category.replaceAll('_', ' ')} · ${report.case.countryCode}` : ''}</p>
      <div className="reportActions"><button className="ghost" disabled={busyId === report.id} onClick={() => void update(report.id, 'IN_REVIEW')}>Mark in review</button><button className="ghost" disabled={busyId === report.id} onClick={() => void update(report.id, 'DISMISSED')}>Dismiss</button><button className="primary" disabled={busyId === report.id} onClick={() => void update(report.id, 'RESOLVED')}>{busyId === report.id ? 'Saving…' : 'Resolve'}</button></div>
    </article>)}</section>
  </>;
}
