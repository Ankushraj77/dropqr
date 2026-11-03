import Link from "next/link";
const navigation = [
  { label: "Overview", icon: "◫", current: true },
  { label: "File inbox", icon: "▤" },
  { label: "Document studio", icon: "✳" },
  { label: "QR stations", icon: "⌗" },
  { label: "Processing history", icon: "↺" },
];

const setupSteps = [
  { number: "01", title: "Connect your shop", detail: "Create the first secure shop workspace." },
  { number: "02", title: "Invite your team", detail: "Set access for the people who handle files." },
  { number: "03", title: "Create an upload station", detail: "Give customers a simple way to send files." },
];

export default function Home() {
  return (
    <main className="app-shell">
      <aside className="sidebar" aria-label="Main navigation">
        <Link className="brand" href="/" aria-label="DROPQR Studio overview">
          <span className="brand-mark" aria-hidden="true">D</span>
          <span className="brand-name">dropqr<span>studio</span></span>
        </Link>

        <div className="workspace-picker" aria-label="Current workspace">
          <span className="workspace-avatar">A</span>
          <span className="workspace-copy"><strong>AK Digital Services</strong><small>Workspace setup</small></span>
          <span className="picker-chevron" aria-hidden="true">⌄</span>
        </div>

        <p className="nav-label">WORKSPACE</p>
        <nav className="nav-list">
          {navigation.map((item) => (
            <div
              key={item.label}
              className={`nav-item${item.current ? " active" : " disabled"}`}
              aria-current={item.current ? "page" : undefined}
              aria-disabled={!item.current}
              title={!item.current ? "Available after workspace setup" : undefined}
            >
              <span className="nav-icon" aria-hidden="true">{item.icon}</span>
              <span>{item.label}</span>
              {!item.current && <span className="nav-lock" aria-label="Not available yet">·</span>}
            </div>
          ))}
        </nav>

        <div className="sidebar-bottom">
          <div className="help-card">
            <span className="help-icon" aria-hidden="true">?</span>
            <div><strong>Getting started</strong><span>Build your workspace step by step.</span></div>
          </div>
          <div className="profile-row">
            <span className="profile-avatar">AK</span>
            <span className="profile-copy"><strong>Account</strong><small>Not connected</small></span>
            <span className="profile-menu" aria-hidden="true">•••</span>
          </div>
        </div>
      </aside>

      <section className="main-panel">
        <header className="topbar">
          <div className="breadcrumbs"><span>AK Digital Services</span><span className="crumb-separator">/</span><strong>Overview</strong></div>
          <div className="topbar-actions">
            <span className="preview-pill"><span className="status-dot" /> Local preview</span>
            <button className="icon-button" type="button" aria-label="Notifications" disabled>♧<span className="notification-dot" /></button>
          </div>
        </header>

        <div className="content-wrap">
          <div className="page-heading">
            <div>
              <p className="eyebrow">WORKSPACE OVERVIEW</p>
              <h1>Your workspace, ready to take shape.</h1>
              <p className="page-intro">Prepare DROPQR Studio for your shop. Secure file receipt stays disabled until the workspace and storage are configured.</p>
            </div>
            <span className="heading-decoration" aria-hidden="true">✳</span>
          </div>

          <section className="setup-banner" aria-labelledby="setup-title">
            <div className="banner-art" aria-hidden="true"><span className="art-sheet sheet-back" /><span className="art-sheet sheet-front"><i /><i /><i /></span><span className="art-spark">✦</span></div>
            <div className="banner-copy">
              <span className="banner-kicker"><span className="status-dot" /> WORKSPACE NOT CONNECTED</span>
              <h2 id="setup-title">Start with a secure shop workspace</h2>
              <p>Authentication and shop membership are not connected yet. The setup flow will create your workspace before any customer files can arrive.</p>
              <button className="primary-button" type="button" disabled aria-disabled="true">Setup flow coming next <span aria-hidden="true">→</span></button>
            </div>
            <div className="banner-orbit orbit-one" aria-hidden="true" />
            <div className="banner-orbit orbit-two" aria-hidden="true" />
          </section>

          <div className="section-heading">
            <div><h2>Workspace overview</h2><p>Live shop activity will appear here after setup.</p></div>
            <span className="muted-tag">NO LIVE DATA YET</span>
          </div>

          <section className="stat-grid" aria-label="Workspace activity summary">
            <article className="stat-card"><div className="stat-label"><span>Upload stations</span><span className="stat-icon violet">⌗</span></div><p className="stat-value">—</p><p className="stat-foot">Create your first QR station</p></article>
            <article className="stat-card"><div className="stat-label"><span>Files received</span><span className="stat-icon mint">▤</span></div><p className="stat-value">—</p><p className="stat-foot">Inbox opens after setup</p></article>
            <article className="stat-card"><div className="stat-label"><span>Ready to process</span><span className="stat-icon peach">✳</span></div><p className="stat-value">—</p><p className="stat-foot">Processing follows uploads</p></article>
          </section>

          <div className="lower-grid">
            <section className="panel setup-panel">
              <div className="section-heading compact"><div><h2>Getting started</h2><p>Three steps to your first customer upload.</p></div><span className="step-count">0 / 3</span></div>
              <ol className="setup-list">
                {setupSteps.map((step) => <li key={step.number}><span className="step-number">{step.number}</span><span className="step-copy"><strong>{step.title}</strong><small>{step.detail}</small></span><span className="step-state" aria-label="Not started">○</span></li>)}
              </ol>
            </section>
            <section className="panel privacy-panel">
              <div className="privacy-icon" aria-hidden="true">◇</div>
              <p className="eyebrow">PRIVACY FOUNDATIONS IN PROGRESS</p>
              <h2>Secure uploads come after setup.</h2>
              <p>This preview stores no customer files. Authentication, tenant policies and private storage need configuration before uploads are enabled.</p>
              <span className="privacy-note"><span className="status-dot" /> No customer files are stored in this preview</span>
            </section>
          </div>

          <footer className="page-footer"><span>DROPQR Studio <span className="footer-dot">·</span> Early foundation</span><span>AK Digital Services <span className="footer-dot">·</span> Multi-tenant foundation in progress</span></footer>
        </div>
      </section>
    </main>
  );
}
