'type Tab' = 'overview' | 'discover' | 'trust' | 'impact' | 'organizations' | 'countries' | 'circles' | 'security' | 'media' | 'global' | 'audit' | 'fraud';

interface SidebarProps {
  open: boolean;
  tab: string;
  setTab: (tab: any) => void;
  setOpen: (open: boolean) => void;
  tabs: { id: string; label: string; icon: string }[];
}

export function Sidebar({ open, tab, setTab, setOpen, tabs }: SidebarProps) {
  return (
    <>
      <aside className={open ? 'drawer open' : 'drawer'}>
        <div className="sideBrand">
          <div className="mark">H</div>
          <div>
            <strong>Helpi</strong>
            <span>Humanitarian operations</span>
          </div>
        </div>
        {tabs.map((x) => (
          <button
            className={tab === x.id ? 'side active' : 'side'}
            onClick={() => {
              setTab(x.id);
              setOpen(false);
            }}
            key={x.id}
          >
            <span>{x.icon}</span>
            {x.label}
          </button>
        ))}
        <div className="sideBottom">
          <div className="securePill">
            <b>Protected workspace</b>
            <small>Least privilege • audit logging</small>
          </div>
          <button
            className="signout"
            onClick={() => {
              localStorage.removeItem('helpi_admin_token');
              location.reload();
            }}
          >
            Sign out
          </button>
        </div>
      </aside>
      <div className="scrim" onClick={() => setOpen(false)} />
    </>
  );
}
