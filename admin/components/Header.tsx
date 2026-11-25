interface HeaderProps {
  setOpen: (open: boolean) => void;
  search: string;
  setSearch: (search: string) => void;
  setTab: (tab: any) => void;
}

export function Header({ setOpen, search, setSearch, setTab }: HeaderProps) {
  return (
    <header>
      <button className="menu" onClick={() => setOpen(true)} aria-label="Open navigation">Menu</button>
      <div className="brand">
        <div className="mark">H</div>
        <div><strong>Helpi</strong><span>Community admin</span></div>
      </div>
      <div className="headerRight">
        <label className="search"><span aria-hidden="true">Search</span><input value={search} onChange={(event) => setSearch(event.target.value)} aria-label="Search workspace" placeholder="Search requests, people, organizations…" /></label>
        <button className="iconBtn" aria-label="Community safety reports" onClick={() => setTab('safety')}>!</button>
        <button className="avatar" aria-label="Administrator account">A</button>
      </div>
    </header>
  );
}
