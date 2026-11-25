'use client';
import { useEffect, useMemo, useState } from 'react';
import { adminFetch } from '../lib/api';

const groups: Record<string, string> = {
  ORPHAN: 'Orphan', WIDOW: 'Widow', WAR_SURVIVOR: 'War survivor',
  DISABILITY: 'Person with a disability', ELDERLY: 'Older adult',
  DISPLACED_PERSON: 'Refugee or displaced person', SINGLE_PARENT: 'Single parent',
  UNEMPLOYED: 'Unemployed person', LOW_INCOME_FAMILY: 'Low-income family',
  CAREGIVER: 'Caregiver', CHRONIC_ILLNESS: 'Person with a chronic illness',
  HOMELESS: 'Person without stable housing', TRAFFICKING_SURVIVOR: 'Survivor of trafficking or abuse',
  OTHER: 'Other',
};
type SupportRequest = {
  id: string; category: string; goalMinor: number; currency: string;
  countryCode: string; city?: string | null; requesterName: string; createdAt: string; status: 'PUBLISHED' | 'PAUSED';
};

export function RequestsView({ token, search }: { token: string; search: string }) {
  const [requests, setRequests] = useState<SupportRequest[]>([]);
  const [category, setCategory] = useState('ALL');
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState('');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await adminFetch('/admin/requests', {}, token);
      if (!response.ok) throw new Error('Could not load support requests.');
      setRequests(await response.json());
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not connect to Helpi.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { void load(); }, [token]);

  const updateStatus = async (request: SupportRequest) => {
    const status = request.status === 'PUBLISHED' ? 'PAUSED' : 'PUBLISHED';
    setBusyId(request.id);
    setError('');
    setNotice('');
    try {
      const response = await adminFetch(`/admin/requests/${request.id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      }, token);
      const result = await response.json();
      if (!response.ok) throw new Error(result.message || 'Could not update request visibility.');
      setNotice(`Request ${status === 'PAUSED' ? 'paused' : 'published'}.`);
      await load();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not update request visibility.');
    } finally {
      setBusyId('');
    }
  };

  const visible = useMemo(() => requests.filter((request) => {
    const matchesGroup = category === 'ALL' || request.category === category;
    const term = search.trim().toLowerCase();
    const matchesSearch = !term || [
      request.requesterName, request.category, request.countryCode, request.city || '',
    ].some((value) => value.toLowerCase().includes(term));
    return matchesGroup && matchesSearch;
  }), [requests, category, search]);

  return (
    <>
      <section className="sectionHead requestHeading">
        <div><p className="eyebrow">FINANCIAL SUPPORT</p><h1>Support requests</h1><p>Browse requests by support group and requested amount.</p></div>
        <button className="ghost" onClick={() => void load()} disabled={loading}>Refresh</button>
      </section>
      <div className="requestFilters">
        <label htmlFor="request-group">Support group</label>
        <select id="request-group" value={category} onChange={(event) => setCategory(event.target.value)}>
          <option value="ALL">All groups</option>
          {Object.entries(groups).map(([value, label]) => <option key={value} value={value}>{label}</option>)}
        </select>
        <span>{visible.length} {visible.length === 1 ? 'request' : 'requests'}</span>
      </div>
      {error && <div className="alert" role="alert">{error}</div>}
      {notice && <div className="inlineStatus ok" role="status">{notice}</div>}
      {loading && <div className="inlineStatus">Loading requests…</div>}
      {!loading && !error && visible.length === 0 && <div className="emptyState"><h3>No requests found</h3><p>Try another group or search.</p></div>}
      <section className="requestGrid">
        {visible.map((request) => (
          <article className="requestCard" key={request.id}>
            <div className="requestCardTop"><span className="groupTag">{groups[request.category] || request.category}</span><span>{request.countryCode}{request.city ? ` · ${request.city}` : ''}</span></div>
            <h2>{request.requesterName}</h2>
            <p className="requestedAmount">{new Intl.NumberFormat(undefined, { maximumFractionDigits: 0 }).format(request.goalMinor / 100)} {request.currency} <span>requested</span></p>
            <small>Posted {new Date(request.createdAt).toLocaleDateString()}</small>
            <div className="reportActions"><span className={`statusBadge ${request.status.toLowerCase()}`}>{request.status === 'PAUSED' ? 'Paused · hidden from browse' : 'Published'}</span><button className={request.status === 'PUBLISHED' ? 'ghost smallAction' : 'primary smallAction'} disabled={busyId === request.id} onClick={() => void updateStatus(request)}>{busyId === request.id ? 'Saving…' : request.status === 'PUBLISHED' ? 'Pause request' : 'Restore request'}</button></div>
          </article>
        ))}
      </section>
    </>
  );
}
