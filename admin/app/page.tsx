'use client';

import { FormEvent, useEffect, useState } from 'react';
import { AuditTrailView } from '../components/AuditTrailView';
import { DashboardOverview } from '../components/DashboardOverview';
import { Header } from '../components/Header';
import { OrganizationsView } from '../components/OrganizationsView';
import { PeopleView } from '../components/PeopleView';
import { RequestsView } from '../components/RequestsView';
import { SafetyReportsView } from '../components/SafetyReportsView';
import { Sidebar } from '../components/Sidebar';
import { adminFetch, api, clearAdminSession, saveAdminSession } from '../lib/api';

type Tab = 'overview' | 'requests' | 'people' | 'organizations' | 'safety' | 'audit';
type Dashboard = {
  users: number;
  activeUsers: number;
  pendingUsers: number;
  suspendedUsers: number;
  publishedRequests: number;
  openReports: number;
  safeguarding: number;
  organizations: number;
  requestGroups: { category: string; _count: { _all: number } }[];
};

const tabs: { id: Tab; label: string; icon: string }[] = [
  { id: 'overview', label: 'Dashboard', icon: 'H' },
  { id: 'requests', label: 'Requests', icon: 'R' },
  { id: 'people', label: 'People', icon: 'P' },
  { id: 'organizations', label: 'Organizations', icon: 'O' },
  { id: 'safety', label: 'Safety reports', icon: '!' },
  { id: 'audit', label: 'Audit trail', icon: 'A' },
];

const featureCards: [string, string, Tab][] = [
  ['Support requests', 'Browse requests by support group and amount.', 'requests'],
  ['People', 'Manage member accounts and access.', 'people'],
  ['Organizations', 'See NGOs and community partners.', 'organizations'],
  ['Community safety', 'Review community conduct reports.', 'safety'],
];

const titles: Record<Tab, string> = {
  overview: 'Connect people with support.',
  requests: 'Requests by support group.',
  people: 'Community accounts and access.',
  organizations: 'Organizations and community helpers.',
  safety: 'Support a safe community.',
  audit: 'Review administrator activity.',
};

export default function Page() {
  const [token, setToken] = useState('');
  const [d, setD] = useState<Dashboard | null>(null);
  const [tab, setTab] = useState<Tab>('overview');
  const [error, setError] = useState('');
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [mfaCode, setMfaCode] = useState('');
  const [busy, setBusy] = useState(false);

  const load = async (authToken: string) => {
    try {
      const response = await adminFetch('/admin/dashboard', {}, authToken);
      if (!response.ok) {
        if (response.status === 401 || response.status === 403) {
          clearAdminSession();
          setToken('');
        }
        throw new Error(response.status === 403 ? 'Administrator access is required.' : 'Could not load the admin dashboard.');
      }
      setD(await response.json());
      setError('');
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Could not connect to Helpi.');
    }
  };

  useEffect(() => {
    const saved = sessionStorage.getItem('helpi_admin_token') || '';
    if (saved) {
      setToken(saved);
      void load(saved);
    }
  }, []);

  useEffect(() => {
    const expire = () => {
      setToken('');
      setD(null);
      setError('Your admin session expired. Sign in again.');
    };
    window.addEventListener('helpi-admin-session-expired', expire);
    return () => window.removeEventListener('helpi-admin-session-expired', expire);
  }, []);

  const signIn = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setBusy(true);
    setError('');
    try {
      const response = await fetch(`${api}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, ...(mfaCode ? { mfaCode } : {}) }),
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.message || 'Sign-in failed.');
      if (result.user?.role !== 'ADMIN') throw new Error('This account is not an administrator.');
      saveAdminSession(result.accessToken, result.refreshToken);
      setToken(result.accessToken);
      await load(result.accessToken);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Sign-in failed.');
    } finally {
      setBusy(false);
    }
  };

  const signOut = () => {
    const refreshToken = sessionStorage.getItem('helpi_admin_refresh_token');
    if (refreshToken) {
      void fetch(`${api}/auth/logout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
    }
    clearAdminSession();
    setToken('');
    setD(null);
    setError('');
  };

  if (!token) {
    return (
      <main className="loginPage">
        <form className="loginCard" onSubmit={signIn}>
          <div className="mark">H</div>
          <p className="eyebrow">HELPI ADMIN</p>
          <h1>Welcome back</h1>
          <p>Sign in to manage community accounts, requests, organizations, and safety reports.</p>
          <label>Email<input type="email" value={email} onChange={(event) => setEmail(event.target.value)} required autoComplete="username" /></label>
          <label>Password<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} required autoComplete="current-password" /></label>
          <label>Authenticator code <span className="muted">If enabled</span><input inputMode="numeric" value={mfaCode} onChange={(event) => setMfaCode(event.target.value.replace(/\D/g, '').slice(0, 6))} maxLength={6} autoComplete="one-time-code" /></label>
          {error && <div className="alert" role="alert">{error}</div>}
          <button className="primary" disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
        </form>
      </main>
    );
  }

  const cards: [string, number | undefined, string][] = [
    ['Active people', d?.activeUsers, 'accounts'],
    ['Requests', d?.publishedRequests, 'published'],
    ['Pending accounts', d?.pendingUsers, 'awaiting account activation'],
    ['Open reports', d?.openReports, 'awaiting review'],
    ['Safeguarding cases', d?.safeguarding, 'open or being investigated'],
    ['Organizations', d?.organizations, 'community partners'],
  ];

  return (
    <main>
      <Sidebar open={open} tab={tab} setTab={setTab} setOpen={setOpen} tabs={tabs} onSignOut={signOut} />
      <section className="content">
        <Header setOpen={setOpen} search={search} setSearch={setSearch} setTab={setTab} />
        <label className="mobileSearch"><span>Search workspace</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Requests, people, organizations…" /></label>
        <nav className="mobileTabs" aria-label="Admin sections">
          {tabs.map((item) => <button className={tab === item.id ? 'active' : ''} onClick={() => setTab(item.id)} key={item.id}>{item.label}</button>)}
        </nav>
        {tab === 'overview' ? <DashboardOverview d={d} title={titles[tab]} error={error} load={() => void load(token)} setTab={setTab} cards={cards} featureCards={featureCards} />
          : tab === 'requests' ? <RequestsView token={token} search={search} />
            : tab === 'people' ? <PeopleView token={token} search={search} />
              : tab === 'organizations' ? <OrganizationsView token={token} search={search} />
                : tab === 'safety' ? <SafetyReportsView token={token} search={search} />
                  : <AuditTrailView token={token} search={search} />}
      </section>
    </main>
  );
}
