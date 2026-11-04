import Link from "next/link";
import Image from "next/image";
import QRCode from "qrcode";
import { redirect } from "next/navigation";
import { createQrStationAction, signOutAction, updateQrStationAction, updateShopSettingsAction } from "@/app/actions";
import { createClient } from "@/lib/supabase/server";

type Membership = { shop_id: string; role: "owner" | "employee" };
type Station = { id: string; station_code: string; name: string; is_active: boolean; created_at: string };
type ShopSettings = {
  max_file_size_bytes: number;
  max_files_per_session: number;
  max_total_bytes_per_session: number;
  session_ttl_hours: number;
};

// The authenticated dashboard reads the request session and tenant data.
export const instant = false;

const initialSettings: ShopSettings = {
  max_file_size_bytes: 26214400,
  max_files_per_session: 20,
  max_total_bytes_per_session: 104857600,
  session_ttl_hours: 24,
};

export default async function Home({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: memberships } = await supabase.from("shop_memberships")
    .select("shop_id, role")
    .eq("user_id", user.id)
    .eq("status", "active")
    .order("created_at", { ascending: true })
    .limit(1);
  const membership = (memberships?.[0] ?? null) as Membership | null;
  if (!membership) redirect("/onboarding");

  const [{ data: shop }, { data: stationRows }, { data: settingRow }] = await Promise.all([
    supabase.from("shops").select("id, name").eq("id", membership.shop_id).maybeSingle(),
    supabase.from("qr_stations").select("id, station_code, name, is_active, created_at").eq("shop_id", membership.shop_id).order("created_at", { ascending: false }),
    supabase.from("shop_settings").select("max_file_size_bytes, max_files_per_session, max_total_bytes_per_session, session_ttl_hours").eq("shop_id", membership.shop_id).maybeSingle(),
  ]);
  const stations = (stationRows ?? []) as Station[];
  const settings = (settingRow ?? initialSettings) as ShopSettings;
  const isOwner = membership.role === "owner";
  const { error: actionError } = await searchParams;
  const appOrigin = process.env.VERCEL_ENV === "preview" && process.env.VERCEL_URL
    ? `https://${process.env.VERCEL_URL}`
    : process.env.NEXT_PUBLIC_APP_URL
      ?? (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : "http://localhost:3000");
  const stationQr = await Promise.all(stations.map(async (station) => {
    const uploadUrl = new URL(`/upload/${station.station_code}`, appOrigin).toString();
    return { ...station, uploadUrl, qrDataUrl: station.is_active ? await QRCode.toDataURL(uploadUrl, { width: 220, margin: 1, errorCorrectionLevel: "M" }) : null };
  }));
  const errorText: Record<string, string> = {
    "station-input": "Check the station name and try again.",
    "station-create": "The station could not be created. Your owner access and shop connection may have changed.",
    "station-update": "The station could not be updated.",
    "settings-input": "Enter whole-number limits within the listed platform caps.",
    "settings-update": "The upload settings could not be saved.",
  };

  return (
    <main className="app-shell">
      <aside className="sidebar" aria-label="Main navigation">
        <Link className="brand" href="/" aria-label="DROPQR Studio overview"><span className="brand-mark" aria-hidden="true">D</span><span className="brand-name">dropqr<span>studio</span></span></Link>
        <div className="workspace-picker"><span className="workspace-avatar">{(shop?.name ?? "S").slice(0, 1).toUpperCase()}</span><span className="workspace-copy"><strong>{shop?.name ?? "Shop workspace"}</strong><small>{isOwner ? "Owner" : "Employee"}</small></span><span className="picker-chevron" aria-hidden="true">⌄</span></div>
        <p className="nav-label">WORKSPACE</p>
        <nav className="nav-list">
          <Link className="nav-item active" href="/" aria-current="page"><span className="nav-icon" aria-hidden="true">◫</span><span>Overview</span></Link>
          <span className="nav-item disabled" aria-disabled="true"><span className="nav-icon" aria-hidden="true">▤</span><span>File inbox</span><span className="nav-lock">·</span></span>
          <span className="nav-item disabled" aria-disabled="true"><span className="nav-icon" aria-hidden="true">✳</span><span>Document Studio</span><span className="nav-lock">·</span></span>
          <a className="nav-item active" href="#stations"><span className="nav-icon" aria-hidden="true">⌗</span><span>QR stations</span></a>
        </nav>
        <div className="sidebar-bottom"><div className="help-card"><span className="help-icon" aria-hidden="true">?</span><div><strong>Secure setup</strong><span>Customer uploads arrive in private, temporary sessions.</span></div></div><div className="profile-row"><span className="profile-avatar">{(user.email ?? "U").slice(0, 1).toUpperCase()}</span><span className="profile-copy"><strong>{user.email ?? "Signed in"}</strong><small>{isOwner ? "Shop owner" : "Shop employee"}</small></span><form action={signOutAction}><button className="quiet-button compact-quiet" type="submit">Sign out</button></form></div></div>
      </aside>

      <section className="main-panel">
        <header className="topbar"><div className="breadcrumbs"><span>{shop?.name ?? "Shop"}</span><span className="crumb-separator">/</span><strong>Overview</strong></div><div className="topbar-actions"><span className="preview-pill"><span className="status-dot" /> Shop setup</span></div></header>
        <div className="content-wrap">
          <div className="page-heading"><div><p className="eyebrow">SHOP WORKSPACE</p><h1>{shop?.name ?? "Your shop"}</h1><p className="page-intro">Manage permanent QR stations and the upload limits for new customer sessions.</p></div><span className="heading-decoration" aria-hidden="true">✳</span></div>
          <section className="setup-banner active-banner"><div className="banner-copy"><span className="banner-kicker"><span className="status-dot" /> PRIVATE BY DEFAULT</span><h2>Your shop workspace is connected</h2><p>Permanent QR codes identify this shop’s upload entry point. Each customer upload will later receive its own temporary session; a station QR never exposes existing files.</p><span className="setup-status">{stations.length} station{stations.length === 1 ? "" : "s"} · {stations.filter((station) => station.is_active).length} active</span></div><div className="banner-orbit orbit-one" aria-hidden="true"/><div className="banner-orbit orbit-two" aria-hidden="true"/></section>

          {actionError && errorText[actionError] && <p className="form-message error page-message" role="alert">{errorText[actionError]}</p>}

          <div className="section-heading" id="stations"><div><h2>QR stations</h2><p>Create and manage the permanent upload entry points in your shop.</p></div><span className="muted-tag">{stations.length} TOTAL</span></div>
          {isOwner && <section className="panel station-create-panel"><div><h3>Create a station</h3><p>Each station gets a printable QR code. You can disable it at any time.</p></div><form className="inline-form" action={createQrStationAction}><input type="hidden" name="shop_id" value={membership.shop_id}/><label className="sr-only" htmlFor="station-name">Station name</label><input id="station-name" name="name" type="text" required minLength={1} maxLength={80} placeholder="For example, Front counter"/><button className="primary-button active-button" type="submit">Add station<span aria-hidden="true">→</span></button></form></section>}

          {stationQr.length ? <section className="station-grid" aria-label="QR stations">{stationQr.map((station) => <article className={`panel station-card${station.is_active ? "" : " station-inactive"}`} key={station.id}>
            {station.qrDataUrl ? <Image className="station-qr" src={station.qrDataUrl} alt={`QR code for ${station.name}`} width={220} height={220} unoptimized/> : <div className="qr-disabled" aria-label="QR station disabled">Paused</div>}
            <div className="station-details"><div className="station-title-row"><div><p className="eyebrow">PERMANENT STATION</p><h3>{station.name}</h3></div><span className={`status-chip${station.is_active ? " live" : " paused"}`}>{station.is_active ? "Active" : "Disabled"}</span></div><p className="station-url">{station.uploadUrl}</p><p className="station-note">This public code identifies the shop only. It cannot read, list, or delete uploaded files.</p>{isOwner && <form className="station-edit-form" action={updateQrStationAction}><input type="hidden" name="shop_id" value={membership.shop_id}/><input type="hidden" name="station_id" value={station.id}/><label><span className="sr-only">Station name</span><input name="name" required minLength={1} maxLength={80} defaultValue={station.name}/></label><input type="hidden" name="is_active" value={String(!station.is_active)}/><button className="secondary-button" type="submit">{station.is_active ? "Disable station" : "Reactivate station"}</button></form>}</div>
          </article>)}</section> : <section className="panel empty-panel"><span className="empty-icon" aria-hidden="true">⌗</span><h3>No QR stations yet</h3><p>{isOwner ? "Create a station for a counter, service desk, or other customer handoff point." : "A shop owner can add QR stations for your team to use."}</p></section>}

          <div className="section-heading settings-heading"><div><h2>Customer upload limits</h2><p>Defaults for temporary sessions. Values can be lowered up to platform caps.</p></div><span className="muted-tag">CONFIGURABLE</span></div>
          <section className="panel settings-panel"><form className="settings-form" action={isOwner ? updateShopSettingsAction : undefined}>
            <input type="hidden" name="shop_id" value={membership.shop_id}/>
            <label>Max file size <span>Platform cap: 25 MB</span><div className="input-suffix"><input name="max_file_size_mb" type="number" min="1" max="25" step="1" defaultValue={Math.floor(settings.max_file_size_bytes / 1048576)} disabled={!isOwner}/><small>MB</small></div></label>
            <label>Files per session <span>Platform cap: 20 files</span><div className="input-suffix"><input name="max_files_per_session" type="number" min="1" max="20" step="1" defaultValue={settings.max_files_per_session} disabled={!isOwner}/><small>files</small></div></label>
            <label>Total size per session <span>Platform cap: 100 MB</span><div className="input-suffix"><input name="max_total_mb_per_session" type="number" min="1" max="100" step="1" defaultValue={Math.floor(settings.max_total_bytes_per_session / 1048576)} disabled={!isOwner}/><small>MB</small></div></label>
            <label>Session lifetime <span>Platform cap: 24 hours</span><div className="input-suffix"><input name="session_ttl_hours" type="number" min="1" max="24" step="1" defaultValue={settings.session_ttl_hours} disabled={!isOwner}/><small>hours</small></div></label>
            {isOwner && <button className="primary-button active-button settings-save" type="submit">Save upload limits<span aria-hidden="true">→</span></button>}
          </form><p className="settings-note">The current session caps start at 25 MB per file, 20 files, 100 MB total, and 24 hours. Upload enforcement and cleanup will be enabled in the next implementation milestones.</p></section>

          <footer className="page-footer"><span>DROPQR Studio <span className="footer-dot">·</span> Phase 2 foundation</span><span>Original customer files remain private</span></footer>
        </div>
      </section>
    </main>
  );
}
