import { HelpiLogo } from './HelpiLogo';

interface SidebarProps {
  open: boolean;
  tab: string;
  setTab: (tab: any) => void;
  setOpen: (open: boolean) => void;
  tabs: { id: string; label: string; icon: string }[];
  onSignOut: () => void;
}

export function Sidebar({ open, tab, setTab, setOpen, tabs, onSignOut }: SidebarProps) {
  const groups = [
    { label: 'Community', items: tabs.filter((item) => ['overview', 'requests', 'people', 'organizations'].includes(item.id)) },
    { label: 'Oversight', items: tabs.filter((item) => ['safety', 'audit'].includes(item.id)) },
  ];

  return <>
    <aside className={open ? 'drawer open' : 'drawer'} aria-label="Admin navigation">
      <div className="sideBrand"><HelpiLogo className="brandLogo" /><div><strong>Helpi</strong><span>Community admin</span></div></div>
      <nav className="sideNav">{groups.map((group) => <div className="sideNavGroup" key={group.label}>
        <small>{group.label}</small>
        {group.items.map((item) => <button className={tab === item.id ? 'side active' : 'side'} onClick={() => { setTab(item.id); setOpen(false); }} key={item.id} aria-current={tab === item.id ? 'page' : undefined}>
          <span className="sideIcon" aria-hidden="true">{item.icon}</span>{item.label}
        </button>)}
      </div>)}</nav>
      <div className="sideBottom"><div className="securePill"><b>Protected workspace</b><small>Admin-only access · activity is recorded</small></div><button className="signout" onClick={onSignOut}>Sign out</button></div>
    </aside>
    <button className="scrim" onClick={() => setOpen(false)} aria-label="Close navigation" />
  </>;
}
