interface HeaderProps {
  setOpen: (open: boolean) => void;
  search: string;
  setSearch: (search: string) => void;
  setTab: (tab: any) => void;
}

export function Header({ setOpen, search, setSearch, setTab }: HeaderProps) {
  return (
    <header>
      <button className="menu" onClick={() => setOpen(true)} aria-label="Open Menu">
        ☰
      </button>
      <div className="brand">
        <div className="mark">H</div>
        <div>
          <strong>Helpi</strong>
          <span>Real help. Global impact.</span>
        </div>
      </div>
      <div className="headerRight">
        <div className="search">
          ⌕{' '}
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            aria-label="Search"
            placeholder="Search cases, people, organizations..."
          />
        </div>
        <button className="iconBtn" aria-label="Notifications" onClick={() => setTab('media')}>
          ●
        </button>
        <button className="avatar" aria-label="Admin User">A</button>
      </div>
    </header>
  );
}
