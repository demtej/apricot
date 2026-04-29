/* Apricot — Transaction detail screen */

const TxScreen = ({ onBack }) => {
  const { Icon } = window.ApricotKit;
  const [showAdvanced, setShowAdvanced] = useState(false);

  return (
    <div style={{width: "100%", height: "100%", background: "var(--bg-surface)", display: "flex", flexDirection: "column", overflow: "auto"}}>
      {/* Top bar */}
      <div style={{padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", background: "var(--bg-page)"}}>
        <button onClick={onBack} style={{all: "unset", cursor: "pointer", color: "var(--fg-primary)", padding: 4}}><Icon.back /></button>
        <div style={{fontSize: 14, fontWeight: 500, color: "var(--fg-primary)"}}>Transaction</div>
        <button style={{all: "unset", cursor: "pointer", color: "var(--fg-primary)", padding: 4}}><Icon.more /></button>
      </div>

      {/* Plain-language summary */}
      <div style={{padding: "8px 16px 4px"}}>
        <div className="card" style={{padding: 22, borderRadius: 20, boxShadow: "var(--shadow-sm)"}}>
          <div style={{display: "flex", alignItems: "center", gap: 10, marginBottom: 14}}>
            <div className="tx-icon tx-icon-in" style={{width: 44, height: 44}}><Icon.arrowDown size={22} /></div>
            <div>
              <span className="badge badge-in"><span className="badge-dot"></span>Received</span>
            </div>
          </div>
          <div style={{fontFamily: "var(--font-mono)", fontSize: 32, fontWeight: 500, lineHeight: 1, color: "var(--sage-600)", letterSpacing: "-0.01em", fontVariantNumeric: "tabular-nums"}}>
            + 0.01250<span style={{fontSize: 14, color: "var(--fg-secondary)", marginLeft: 6}}>BTC</span>
          </div>
          <div style={{fontSize: 13, color: "var(--fg-secondary)", marginTop: 4}}>≈ $814.62 USD</div>
          <div style={{marginTop: 12, fontSize: 14, color: "var(--fg-primary)", lineHeight: 1.45}}>
            From one external wallet · Apr 19, 2024 · Confirmed 2×.
          </div>
        </div>
      </div>

      {/* Quick facts */}
      <div style={{padding: "14px 16px 4px"}}>
        <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8}}>
          <div className="stat-card">
            <span className="label">Confirmations</span>
            <span><span className="value">2</span></span>
          </div>
          <div className="stat-card">
            <span className="label">Fee</span>
            <span><span className="value">4,200</span><span className="unit">sats</span></span>
          </div>
          <div className="stat-card">
            <span className="label">Fee rate</span>
            <span><span className="value">42</span><span className="unit">sat/vB</span></span>
          </div>
          <div className="stat-card">
            <span className="label">When</span>
            <span style={{fontFamily: "var(--font-mono)", fontSize: 14, fontWeight: 500}}>Apr 19, 14:22</span>
          </div>
        </div>
      </div>

      {/* Flow */}
      <div style={{padding: "16px 16px 4px"}}>
        <div className="t-label" style={{marginBottom: 10}}>Flow</div>
        <div className="card" style={{padding: 16}}>
          <div style={{display: "grid", gridTemplateColumns: "1fr 50px 1fr", gap: 10, alignItems: "center"}}>
            <div>
              <div style={{fontSize: 11, color: "var(--fg-secondary)", letterSpacing: "0.04em", textTransform: "uppercase", fontWeight: 500, marginBottom: 6}}>From</div>
              <div style={{background: "var(--bg-surface)", borderRadius: 10, padding: "10px 12px"}}>
                <div style={{fontFamily: "var(--font-mono)", fontSize: 11, color: "var(--fg-secondary)"}}>bc1q…h7d2</div>
                <div style={{fontFamily: "var(--font-mono)", fontSize: 13, fontWeight: 500, color: "var(--fg-primary)", marginTop: 2}}>0.01254</div>
              </div>
            </div>
            <div style={{display: "flex", flexDirection: "column", alignItems: "center", gap: 4}}>
              <div style={{height: 2, width: "100%", background: "linear-gradient(to right, var(--apricot-200), var(--apricot-400))", position: "relative"}}>
                <div style={{position: "absolute", right: -1, top: -4, width: 0, height: 0, borderLeft: "8px solid var(--apricot-400)", borderTop: "5px solid transparent", borderBottom: "5px solid transparent"}}></div>
              </div>
            </div>
            <div>
              <div style={{fontSize: 11, color: "var(--fg-secondary)", letterSpacing: "0.04em", textTransform: "uppercase", fontWeight: 500, marginBottom: 6}}>To</div>
              <div style={{background: "var(--accent-soft)", borderRadius: 10, padding: "10px 12px"}}>
                <div style={{fontFamily: "var(--font-mono)", fontSize: 11, color: "var(--apricot-700)"}}>bc1q…59gt <span style={{fontWeight: 600}}>(this)</span></div>
                <div style={{fontFamily: "var(--font-mono)", fontSize: 13, fontWeight: 500, color: "var(--apricot-800)", marginTop: 2}}>0.01250</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Advanced details (progressive disclosure) */}
      <div style={{padding: "16px 16px 28px"}}>
        <button onClick={() => setShowAdvanced(!showAdvanced)} style={{all: "unset", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "space-between", width: "100%", padding: "12px 14px", background: "var(--bg-elevated)", border: "1px solid var(--border-subtle)", borderRadius: 12}}>
          <span style={{fontSize: 14, fontWeight: 500, color: "var(--fg-primary)"}}>Technical details</span>
          <span style={{transform: showAdvanced ? "rotate(90deg)" : "none", transition: "transform 200ms", color: "var(--fg-muted)"}}><Icon.chevron /></span>
        </button>
        {showAdvanced && (
          <div className="card" style={{marginTop: 8, padding: 16}}>
            <div style={{display: "flex", flexDirection: "column", gap: 10}}>
              {[
                ["Tx ID", "a1075db55d416d3ca199f55b6084e2115b9345e1"],
                ["Block", "#840,127"],
                ["Size", "248 vBytes"],
                ["Version", "2"],
                ["Locktime", "0"],
              ].map(([k,v]) => (
                <div key={k} style={{display: "flex", justifyContent: "space-between", gap: 12}}>
                  <div style={{fontSize: 13, color: "var(--fg-secondary)"}}>{k}</div>
                  <div style={{fontFamily: "var(--font-mono)", fontSize: 12, color: "var(--fg-primary)", textAlign: "right"}}>{v}</div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

window.TxScreen = TxScreen;
