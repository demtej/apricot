/* Apricot — Home / Search screen */

const HomeScreen = ({ onSearch }) => {
  const { Icon, Logo } = window.ApricotKit;
  const [q, setQ] = useState("");

  const recent = [
    { kind: "addr", v: "bc1qar0srrr7xfk…59gtzz", time: "Today" },
    { kind: "tx",   v: "a1075db5…e2115b9345e1", time: "Today" },
    { kind: "addr", v: "1A1zP1eP5QGefi2…vfNa", time: "Yesterday" },
  ];

  return (
    <div style={{
      width: "100%", height: "100%",
      background: "var(--bg-page)",
      display: "flex", flexDirection: "column",
    }}>
      {/* Top brand */}
      <div style={{padding: "8px 20px 8px", display: "flex", alignItems: "center", gap: 10}}>
        <Logo size={32} />
        <div style={{fontSize: 20, fontWeight: 600, letterSpacing: "-0.02em", color: "var(--fg-primary)"}}>Apricot</div>
      </div>

      {/* Hero */}
      <div style={{padding: "16px 20px 14px"}}>
        <div className="t-h1" style={{marginBottom: 6}}>Look up a wallet<br/>or transaction</div>
        <div className="t-caption" style={{maxWidth: 280}}>Paste a Bitcoin address or transaction id. We'll explain what we find.</div>
      </div>

      {/* Search */}
      <div style={{padding: "0 20px 20px"}}>
        <div className="search-wrap">
          <span className="search-icon"><Icon.search /></span>
          <input
            className="search-field"
            placeholder="bc1q…  or  a1075db5…"
            value={q}
            onChange={e => setQ(e.target.value)}
            onKeyDown={e => e.key === "Enter" && onSearch && onSearch(q)}
          />
        </div>
      </div>

      {/* Recent */}
      <div style={{padding: "0 20px"}}>
        <div className="t-label" style={{marginBottom: 10}}>Recent</div>
        <div style={{display: "flex", flexDirection: "column", gap: 8, marginBottom: 24}}>
          {recent.map((r,i) => (
            <button key={i} onClick={() => onSearch && onSearch(r.v)} style={{
              all: "unset", cursor: "pointer",
              display: "flex", alignItems: "center", gap: 12,
              padding: "12px 14px",
              background: "var(--bg-elevated)",
              border: "1px solid var(--border-subtle)",
              borderRadius: "var(--radius-md)",
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: 999,
                background: r.kind === "addr" ? "var(--accent-soft)" : "var(--sky-100)",
                color: r.kind === "addr" ? "var(--apricot-700)" : "var(--sky-600)",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontFamily: "var(--font-mono)", fontSize: 12, fontWeight: 600,
              }}>{r.kind === "addr" ? "bc" : "tx"}</div>
              <div style={{flex: 1, minWidth: 0}}>
                <div style={{fontFamily: "var(--font-mono)", fontSize: 13, color: "var(--fg-primary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap"}}>{r.v}</div>
                <div style={{fontSize: 12, color: "var(--fg-secondary)", marginTop: 2}}>{r.time}</div>
              </div>
              <span style={{color: "var(--fg-muted)"}}><Icon.chevron /></span>
            </button>
          ))}
        </div>
      </div>

    </div>
  );
};

window.HomeScreen = HomeScreen;
