/* Apricot — Loading + Error/Empty states */

const LoadingScreen = ({ onBack }) => {
  const { Icon } = window.ApricotKit;
  return (
    <div style={{width: "100%", height: "100%", background: "var(--bg-surface)", display: "flex", flexDirection: "column"}}>
      <div style={{padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", background: "var(--bg-page)"}}>
        <button onClick={onBack} style={{all: "unset", cursor: "pointer", color: "var(--fg-primary)", padding: 4}}><Icon.back /></button>
        <div style={{fontSize: 14, fontWeight: 500, color: "var(--fg-primary)"}}>Address</div>
        <div style={{width: 22}}></div>
      </div>
      <div style={{padding: "16px"}}>
        <div className="card" style={{padding: 22, borderRadius: 20}}>
          <div className="skeleton" style={{width: 100, height: 11, marginBottom: 10}}></div>
          <div className="skeleton" style={{width: 200, height: 12, marginBottom: 18}}></div>
          <div className="skeleton" style={{width: 180, height: 36, marginBottom: 8}}></div>
          <div className="skeleton" style={{width: 100, height: 12, marginBottom: 16}}></div>
          <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8}}>
            {[0,1,2,3].map(i => (
              <div key={i} style={{background: "var(--bg-surface)", borderRadius: 12, padding: "10px 12px"}}>
                <div className="skeleton" style={{width: 60, height: 10, marginBottom: 6}}></div>
                <div className="skeleton" style={{width: 80, height: 14}}></div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <div style={{padding: "8px 16px", display: "flex", flexDirection: "column", gap: 8}}>
        {[0,1,2].map(i => (
          <div key={i} style={{display: "flex", alignItems: "center", gap: 12, padding: 16, background: "var(--bg-elevated)", border: "1px solid var(--border-subtle)", borderRadius: 12}}>
            <div className="skeleton" style={{width: 40, height: 40, borderRadius: 999}}></div>
            <div style={{flex: 1}}>
              <div className="skeleton" style={{width: "50%", height: 12, marginBottom: 6}}></div>
              <div className="skeleton" style={{width: "30%", height: 10}}></div>
            </div>
            <div className="skeleton" style={{width: 70, height: 14}}></div>
          </div>
        ))}
      </div>
    </div>
  );
};

const ErrorScreen = ({ onBack, onRetry }) => {
  const { Icon } = window.ApricotKit;
  return (
    <div style={{width: "100%", height: "100%", background: "var(--bg-page)", display: "flex", flexDirection: "column"}}>
      <div style={{padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between"}}>
        <button onClick={onBack} style={{all: "unset", cursor: "pointer", color: "var(--fg-primary)", padding: 4}}><Icon.back /></button>
        <div style={{fontSize: 14, fontWeight: 500, color: "var(--fg-primary)"}}>Search</div>
        <div style={{width: 22}}></div>
      </div>
      <div style={{flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 32px", textAlign: "center"}}>
        <div style={{width: 72, height: 72, borderRadius: "50%", background: "var(--out-bg)", color: "var(--out-fg)", display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 18}}>
          <Icon.alert size={28} />
        </div>
        <div className="t-h2" style={{marginBottom: 8}}>We can't reach the network</div>
        <div className="t-caption" style={{maxWidth: 280, marginBottom: 20}}>
          Check your connection and try again. We've kept your search safe.
        </div>
        <button className="btn btn-primary" onClick={onRetry}>Try again</button>
        <button className="btn btn-ghost" style={{marginTop: 6}} onClick={onBack}>Go back</button>
      </div>
    </div>
  );
};

window.LoadingScreen = LoadingScreen;
window.ErrorScreen = ErrorScreen;
