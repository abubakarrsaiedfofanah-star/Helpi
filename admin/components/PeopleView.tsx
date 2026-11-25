'use client';

import { useEffect, useState } from 'react';
import { adminFetch } from '../lib/api';

type Person = {
  id: string;
  name: string;
  email: string;
  role: string;
  status: string;
  supportGroup: string | null;
  countryCode: string;
  createdAt: string;
  lastLoginAt: string | null;
};
type PeopleResult = { items: Person[]; total: number; page: number; pageSize: number };

const groupLabels: Record<string, string> = {
  ORPHAN: 'Orphan', WIDOW: 'Widow', WAR_SURVIVOR: 'War survivor',
  DISABILITY: 'Person with a disability', ELDERLY: 'Older adult',
  DISPLACED_PERSON: 'Refugee or displaced person', SINGLE_PARENT: 'Single parent',
  UNEMPLOYED: 'Unemployed person', LOW_INCOME_FAMILY: 'Low-income family',
  CAREGIVER: 'Caregiver', CHRONIC_ILLNESS: 'Person with chronic illness',
  HOMELESS: 'Person without stable housing', TRAFFICKING_SURVIVOR: 'Survivor of trafficking or abuse',
  OTHER: 'Other',
};

export function PeopleView({ token, search }: { token: string; search: string }) {
  const [data, setData] = useState<PeopleResult | null>(null);
  const [status, setStatus] = useState('ALL');
  const [page, setPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState(search);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState('');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const query = new URLSearchParams({ q: searchTerm, page: String(page), pageSize: '25' });
      if (status !== 'ALL') query.set('status', status);
      const response = await adminFetch(`/admin/users?${query}`, {}, token);
      if (!response.ok) throw new Error('Could not load accounts.');
      setData(await response.json());
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not connect to Helpi.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timer = window.setTimeout(() => setSearchTerm(search.trim()), 250);
    return () => window.clearTimeout(timer);
  }, [search]);

  useEffect(() => { setPage(1); }, [searchTerm, status]);
  useEffect(() => { void load(); }, [token, searchTerm, status, page]);

  const changeStatus = async (person: Person) => {
    const nextStatus = person.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    setBusyId(person.id);
    setError('');
    setNotice('');
    try {
      const response = await adminFetch(`/admin/users/${person.id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: nextStatus }),
      }, token);
      const result = await response.json();
      if (!response.ok) throw new Error(result.message || 'Could not update account.');
      setNotice(`${person.name} is now ${nextStatus.toLowerCase()}.`);
      await load();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not update account.');
    } finally {
      setBusyId('');
    }
  };

  return (
    <>
      <section className="sectionHead requestHeading">
        <div><p className="eyebrow">COMMUNITY ACCOUNTS</p><h1>People</h1><p>Manage account access and see each member’s support group.</p></div>
        <button className="ghost" onClick={() => void load()} disabled={loading}>Refresh</button>
      </section>
      <div className="requestFilters">
        <label htmlFor="people-status">Account status</label>
        <select id="people-status" value={status} onChange={(event) => setStatus(event.target.value)}>
          <option value="ALL">All accounts</option><option value="ACTIVE">Active</option>
          <option value="PENDING">Pending</option><option value="SUSPENDED">Suspended</option>
          <option value="DISABLED">Disabled</option>
        </select>
        <span>{data?.total ?? 0} accounts</span>
      </div>
      {error && <div className="alert" role="alert">{error}</div>}
      {notice && <div className="inlineStatus ok" role="status">{notice}</div>}
      {loading && <div className="inlineStatus">Loading accounts…</div>}
      {!loading && !error && !data?.items.length && <div className="emptyState"><h3>No accounts found</h3><p>Try another status or search term.</p></div>}
      {!!data?.items.length && <div className="tableWrap adminTableWrap"><table className="adminTable">
        <thead><tr><th>Person</th><th>Group</th><th>Country</th><th>Status</th><th>Joined</th><th>Access</th></tr></thead>
        <tbody>{data.items.map((person) => <tr key={person.id}>
          <td><strong>{person.name}</strong><small>{person.email}</small></td>
          <td>{person.supportGroup ? groupLabels[person.supportGroup] || person.supportGroup : person.role === 'ORGANIZATION' ? 'Organization account' : 'Helper'}</td>
          <td>{person.countryCode}</td>
          <td><span className={`statusBadge ${person.status.toLowerCase()}`}>{person.status.toLowerCase().replace('_', ' ')}</span></td>
          <td>{new Date(person.createdAt).toLocaleDateString()}</td>
          <td>{person.role === 'ADMIN' ? <span className="muted">Administrator</span> : <button className="ghost smallAction" disabled={busyId === person.id || person.status === 'PENDING'} onClick={() => void changeStatus(person)}>{busyId === person.id ? 'Saving…' : person.status === 'ACTIVE' ? 'Suspend' : 'Reactivate'}</button>}</td>
        </tr>)}</tbody>
      </table></div>}
      {!!data?.total && <nav className="pagination" aria-label="Account pages">
        <span>Page {data.page} of {Math.max(1, Math.ceil(data.total / data.pageSize))}</span>
        <div><button className="ghost smallAction" disabled={loading || page <= 1} onClick={() => setPage((value) => Math.max(1, value - 1))}>Previous</button>
          <button className="ghost smallAction" disabled={loading || page >= Math.ceil(data.total / data.pageSize)} onClick={() => setPage((value) => value + 1)}>Next</button></div>
      </nav>}
    </>
  );
}
