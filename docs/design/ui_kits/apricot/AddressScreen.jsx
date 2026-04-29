/* Apricot — Address summary screen */

const AddressScreen = ({ onBack, onTx }) => {
  const { Icon } = window.ApricotKit;

  const txs = [
    { id: "tx1", kind: "in",  amt: "0.01250", date: "Apr 19", conf: 2,   from: "bc1q…h7d2" },
    { id: "tx2", kind: "out", amt: "0.00420", date: "Apr 18", conf: 142, to: "bc1q…m4kp" },
    { id: "tx3", kind: "in",  amt: "0.04827", date: "Apr 12", conf: 920, from: "bc1q…59gt" },
    { id: "tx4", kind: "pending", amt: "0.00310", date: "now", conf: 0, to: "bc1q…83qa" },
  ];

  return (
    <div style={{width: "100%", height: "100%", background: "var(--bg-surface)", display: "flex", flexDirection: "column", overflow: "auto"}}>
      {/* Top bar */}
      <div style={{padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", background: "var(--bg-page)"}}>
        <button onClick={onBack} style={{all: "unset", cursor: "pointer", color: "var(--fg-primary)", padding: 4}}><Icon.back /></button>
        <div style={{fontSize: 14, fontWeight: 500, color: "var(--fg-primary)"}}>Address</div>
        <button style={{all: "unset", cursor: "pointer", color: "var(--fg-primary)", padding: 4}}><Icon.more /></button>
      </div>

      {/* Hero summary */}
      <div style={{padding: "16px 16px 4px"}}>
        <div className="card" style={{padding: 22, borderRadius: 20, boxShadow: "var(--shadow-sm)"}}>
          <div style={{display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 14}}>
            <div>
              <div className="t-label" style={{marginBottom: 6}}>This wallet</div>
              <div style={{fontFamily: "var(--font-mono)", fontSize: 13, color: "var(--fg-secondary)", letterSpacing: "-0.01em"}}>bc1qar0srrr7xfk…59gtzz</div>
            </div>
            <span className="badge badge-neutral">P2WPKH</span>
          </div>
          <div style={{fontFamily: "var(--font-mono)", fontSize: 36, fontWeight: 500, lineHeight: 1, color: "var(--fg-primary)", letterSpacing: "-0.01em", fontVariantNumeric: "tabular-nums"}}>
            0.04827<span style={{fontSize: 16, color: "var(--fg-secondary)", marginLeft: 6}}>BTC</span>
          </div>
          <div style={{fontSize: 13, color: "var(--fg-secondary)", marginTop: 6}}>≈ $3,142.18 USD</div>
          <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, marginTop: 14}}>
            <div style={{background: "var(--bg-surface)", borderRadius: 12, padding: "10px 12px"}}>
              <div className="t-label" style={{fontSize: 10}}>Received</div>
              <div style={{fontFamily: "var(--font-mono)", fontSize: 14, fontWeight: 500, color: "var(--fg-primary)", marginTop: 2}}>2.31094</div>
            </div>
            <div style={{background: "var(--bg-surface)", borderRadius: 12, padding: "10px 12px"}}>
              <div className="t-label" style={{fontSize: 10}}>Sent</div>
              <div style={{fontFamily: "var(--font-mono)", fontSize: 14, fontWeight: 500, color: "var(--fg-primary)", marginTop: 2}}>2.26267</div>
            </div>
            <div style={{background: "var(--bg-surface)", borderRadius: 12, padding: "10px 12px"}}>
              <div className="t-label" style={{fontSize: 10}}>Transactions</div>
              <div style={{fontFamily: "var(--font-mono)", fontSize: 14, fontWeight: 500, color: "var(--fg-primary)", marginTop: 2}}>147</div>
            </div>
            <div style={{background: "var(--bg-surface)", borderRadius: 12, padding: "10px 12px"}}>
              <div className="t-label" style={{fontSize: 10}}>First seen</div>
              <div style={{fontFamily: "var(--font-mono)", fontSize: 14, fontWeight: 500, color: "var(--fg-primary)", marginTop: 2}}>2021-08-14</div>
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div style={{padding: "16px 16px 8px", display: "flex", gap: 8}}>
        <span className="chip chip-active">All · 147</span>
        <span className="chip">Received</span>
        <span className="chip">Sent</span>
      </div>

      {/* Tx list */}
      <div style={{padding: "4px 16px 24px", display: "flex", flexDirection: "column", gap: 8}}>
        {txs.map(t => (
          <button key={t.id} onClick={() => onTx && onTx(t)} style={{all: "unset", cursor: "pointer"}}>
            <div className="tx-row">
              <div className={`tx-icon ${t.kind === "in" ? "tx-icon-in" : t.kind === "out" ? "tx-icon-out" : "tx-icon-pending"}`}>
                {t.kind === "in" ? <Icon.arrowDown /> : t.kind === "out" ? <Icon.arrowUp /> : <Icon.clock />}
              </div>
              <div className="tx-main">
                <div className="tx-title">
                  {t.kind === "in" ? "Received" : t.kind === "out" ? "Sent" : "Pending · in mempool"}
                </div>
                <div className="tx-meta">
                  <span>{t.date}</span>
                  {t.conf > 0 && <><span>·</span><span className="t-mono-sm">{t.conf} conf</span></>}
                </div>
              </div>
              <div className={`tx-amount ${t.kind === "in" ? "tx-amount-in" : "tx-amount-out"}`}>
                {t.kind === "in" ? "+ " : "− "}{t.amt}
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};

window.AddressScreen = AddressScreen;
