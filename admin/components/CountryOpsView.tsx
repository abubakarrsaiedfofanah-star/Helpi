'use client';
import { useEffect, useState } from 'react';

const api = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

export function CountryOpsView() {
  const token = typeof window !== 'undefined' ? localStorage.getItem('helpi_admin_token') : '';
  const [countries, setCountries] = useState<any[]>([]);
  const [code, setCode] = useState('KE');
  const [cfg, setCfg] = useState<any>(null);
  const [msg, setMsg] = useState('');
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    const r = await fetch(`${api}/country-operations`, { headers: { Authorization: `Bearer ${token || ''}` } });
    if (!r.ok) { setMsg('Admin authentication required.'); return; }
    const data = await r.json();
    setCountries(data);
    const selected = data.find((x: any) => x.countryCode === code) || data[0];
    if (selected) { setCode(selected.countryCode); setCfg(selected); }
  };

  useEffect(() => { load().finally(() => setLoading(false)); }, []);

  const select = async (c: string) => {
    setCode(c);
    setMsg('');
    const r = await fetch(`${api}/country-operations/${c}`, { headers: { Authorization: `Bearer ${token || ''}` } });
    const x = await r.json();
    setCfg(x);
  };

  const json = (v: any) => JSON.stringify(v ?? {}, null, 2);
  const parse = (v: string) => { try { return JSON.parse(v); } catch { return null; } };

  const save = async () => {
    if (!cfg) return;
    setBusy(true);
    setMsg('');
    try {
      const body = { ...cfg };
      for (const k of ['languages', 'currencies', 'paymentMethods', 'kycRequirements', 'kybRequirements', 'safeguardingRules', 'emergencyResources', 'documentTypes', 'dataRetention', 'helpMethods', 'verificationRules', 'communicationRules']) {
        const parsed = parse(body[k + 'Text'] ?? '');
        if (parsed === null) { setMsg(`Invalid JSON in ${k}.`); return; }
        body[k] = parsed;
        delete body[k + 'Text'];
      }
      delete body.id; delete body.countryName; delete body.continent; delete body.configured; delete body.createdAt; delete body.updatedAt; delete body.updatedById;
      const r = await fetch(`${api}/country-operations/${code}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token || ''}` },
        body: JSON.stringify(body),
      });
      if (!r.ok) { setMsg(await r.text()); return; }
      setCfg(await r.json());
      setMsg('Country configuration saved and audited.');
    } finally {
      setBusy(false);
    }
  };

  if (loading || !cfg) return <section className="workspaceCard"><h2>Country operations</h2><p>{msg || 'Loading country registry…'}</p></section>;

  const fields = [
    ['languages', 'Languages (JSON array)'],
    ['currencies', 'Currencies (JSON array)'],
    ['paymentMethods', 'Payment methods (JSON)'],
    ['kycRequirements', 'KYC requirements (JSON)'],
    ['kybRequirements', 'KYB requirements (JSON)'],
    ['safeguardingRules', 'Safeguarding rules (JSON)'],
    ['emergencyResources', 'Emergency resources (JSON)'],
    ['documentTypes', 'Accepted document types (JSON)'],
    ['dataRetention', 'Data retention (JSON)'],
    ['helpMethods', 'Available help methods (JSON array)'],
    ['verificationRules', 'Verification rules (JSON)'],
    ['communicationRules', 'Communication rules (JSON)']
  ];

  return (
    <>
      <section className="hero compact">
        <div>
          <p className="eyebrow">COUNTRY OPERATIONS • CONFIGURATION</p>
          <h1>Configure once. Operate globally.</h1>
          <p>Each country can have its own language coverage, currency, payment rails, KYC/KYB, safeguarding, emergency resources, document rules, retention and help methods.</p>
        </div>
        <div className="bigNumber">{countries.length}<small>country profiles</small></div>
      </section>
      <section className="countryConfig">
        <div className="workspaceCard">
          <h2>Country</h2>
          <select value={code} onChange={(e) => select(e.target.value)}>
            {countries.map((c) => (<option key={c.countryCode} value={c.countryCode}>{c.countryName} ({c.countryCode})</option>))}
          </select>
          <label className="configToggle"><input type="checkbox" checked={!!cfg.enabled} onChange={(e) => setCfg({ ...cfg, enabled: e.target.checked })} /> Configuration enabled</label>
          <label>Default language<input value={cfg.defaultLanguage || ''} onChange={(e) => setCfg({ ...cfg, defaultLanguage: e.target.value })} /></label>
          <p className="muted">{cfg.continent} • baseline currency: {cfg.currencies?.join?.(', ')}</p>
        </div>
        <div className="configFields">
          {fields.map(([k, label]) => (
            <label key={k}>{label}<textarea value={cfg[k + 'Text'] ?? json(cfg[k])} onChange={(e) => setCfg({ ...cfg, [k + 'Text']: e.target.value })} spellCheck={false} /></label>
          ))}
          <div className="configActions">
            <button className="primary" aria-busy={busy} disabled={busy} onClick={save}>{busy ? 'Saving…' : 'Save country configuration'}</button>
            <button className="ghost" onClick={() => select(code)}>Reload</button>
          </div>
          {msg && <div className="alert">{msg}</div>}
        </div>
      </section>
    </>
  );
}
