'use client';
import { useEffect, useMemo, useState } from 'react';
import { Sidebar } from '../components/Sidebar';
import { Header } from '../components/Header';
import { DashboardOverview } from '../components/DashboardOverview';
import { MediaReviewView } from '../components/MediaReviewView';
import { CountryOpsView } from '../components/CountryOpsView';
import { AuditTrailView } from '../components/AuditTrailView';
import { FraudQueueView } from '../components/FraudQueueView';
import { GenericWorkspaceView } from '../components/GenericWorkspaceView';

const api = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';
type Dashboard = { users: number; cases: number; verificationQueue: number; fraudQueue: number; openReports: number; transactions: number; openSafeguarding: number; organizations: number; helpCircles: number; appeals: number };
type Tab = 'overview' | 'discover' | 'trust' | 'impact' | 'organizations' | 'countries' | 'circles' | 'security' | 'media' | 'global' | 'audit' | 'fraud';

const tabs: { id: Tab; label: string; icon: string }[] = [
  { id: 'overview', label: 'Dashboard', icon: '⌂' },
  { id: 'media', label: 'Media Review', icon: '▶' },
  { id: 'audit', label: 'Audit Trail', icon: '⚖' },
  { id: 'fraud', label: 'Fraud Queue', icon: '⚡' },
  { id: 'discover', label: 'Discover', icon: '⌕' },
  { id: 'trust', label: 'Trust Center', icon: '✓' },
  { id: 'impact', label: 'Impact', icon: '♥' },
  { id: 'organizations', label: 'Organizations', icon: '▣' },
  { id: 'countries', label: 'Countries', icon: '◎' },
  { id: 'circles', label: 'Help Circles', icon: '♧' },
  { id: 'global', label: 'Global Ops', icon: '◉' },
  { id: 'security', label: 'Security', icon: '◆' }
];

const featureCards: [string, string, string][] = [
  ['Verified Help', 'Browse needs that passed the required verification workflow.', 'discover'],
  ['Trust Passport', 'Understand exactly what was checked without turning trust into a score.', 'trust'],
  ['Proof of Impact', 'Follow assistance from contribution to confirmed outcome.', 'impact'],
  ['Organization Network', 'Schools, hospitals, NGOs and community groups can work through one system.', 'organizations'],
  ['Global Help', 'Country-aware discovery, currencies and payment routes.', 'countries'],
  ['Help Circles', 'Coordinate family, friends or community support privately.', 'circles'],
];

export default function Page() {
  const [d, setD] = useState<Dashboard | null>(null);
  const [tab, setTab] = useState<Tab>('overview');
  const [error, setError] = useState('');
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState('');

  const load = () => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('helpi_admin_token') : '';
    fetch(`${api}/admin/dashboard`, { headers: { Authorization: `Bearer ${token || ''}` } })
      .then(async (r) => {
        if (!r.ok) throw new Error('Admin authentication required.');
        return r.json();
      })
      .then(setD)
      .catch((e) => setError(e.message));
  };

  useEffect(load, []);

  const cards: [string, any, string][] = useMemo(() => [
    ['People', d?.users, 'users'],
    ['Active cases', d?.cases, 'cases'],
    ['Verification queue', d?.verificationQueue, 'review'],
    ['Fraud queue', d?.fraudQueue, 'risk'],
    ['Open reports', d?.openReports, 'reports'],
    ['Transactions', d?.transactions, 'payments'],
    ['Safeguarding', d?.openSafeguarding, 'safety'],
    ['Organizations', d?.organizations, 'network'],
    ['Help circles', d?.helpCircles, 'groups'],
    ['Appeals', d?.appeals, 'fairness']
  ], [d]);

  const title = {
    overview: 'Protect people while enabling help.',
    discover: 'Discover verified needs safely.',
    trust: 'Make trust understandable.',
    impact: 'Show where help creates impact.',
    organizations: 'Connect the humanitarian network.',
    countries: 'Help anywhere, with local context.',
    circles: 'Make helping social and coordinated.',
    security: 'Protect the people and the platform.',
    media: 'Review public-facing video evidence safely.',
    global: 'Operate Helpi consistently across countries.',
    audit: 'Immutable administrative audit log.',
    fraud: 'Investigate high-risk signals and fraud queues.'
  }[tab];

  return (
    <main>
      <Sidebar open={open} tab={tab} setTab={setTab} setOpen={setOpen} tabs={tabs} />
      <section className="content">
        <Header setOpen={setOpen} search={search} setSearch={setSearch} setTab={setTab} />
        <div className="mobileTabs">
          {tabs.map((x) => (
            <button className={tab === x.id ? 'active' : ''} onClick={() => setTab(x.id)} key={x.id}>
              {x.label}
            </button>
          ))}
        </div>
        {tab === 'overview' ? (
          <DashboardOverview d={d} title={title} error={error} load={load} setTab={setTab} cards={cards} featureCards={featureCards} />
        ) : tab === 'media' ? (
          <MediaReviewView />
        ) : tab === 'countries' ? (
          <CountryOpsView />
        ) : tab === 'audit' ? (
          <AuditTrailView />
        ) : tab === 'fraud' ? (
          <FraudQueueView />
        ) : (
          <GenericWorkspaceView tab={tab} d={d} search={search} />
        )}
      </section>
    </main>
  );
}
