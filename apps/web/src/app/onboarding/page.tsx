import Link from "next/link";
import { redirect } from "next/navigation";
import { createShopAction, signOutAction } from "@/app/actions";
import { createClient } from "@/lib/supabase/server";

export const instant = false;

export default async function OnboardingPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: memberships } = await supabase.from("shop_memberships")
    .select("shop_id")
    .eq("user_id", user.id)
    .eq("status", "active")
    .limit(1);
  if (memberships?.length) redirect("/");
  const { error } = await searchParams;

  return (
    <main className="auth-page">
      <Link className="brand auth-brand" href="/" aria-label="DROPQR Studio">
        <span className="brand-mark" aria-hidden="true">D</span>
        <span className="brand-name">dropqr<span>studio</span></span>
      </Link>
      <section className="auth-card onboarding-card" aria-labelledby="onboarding-title">
        <p className="eyebrow">STEP 1 OF 3 · SHOP SETUP</p>
        <h1 id="onboarding-title">Connect your shop</h1>
        <p className="auth-intro">Your shop gets a private workspace, owner access, and configurable upload defaults.</p>
        <div className="default-limits" aria-label="Initial configurable upload limits">
          <span><strong>25 MB</strong> per file</span><span><strong>20</strong> files per session</span>
          <span><strong>100 MB</strong> total per session</span><span><strong>24 hours</strong> session lifetime</span>
        </div>
        <form className="form-stack" action={createShopAction}>
          <label>Shop name<input name="name" type="text" autoComplete="organization" required minLength={1} maxLength={120} placeholder="For example, Riverside Print Shop" /></label>
          {error && <p className="form-message error" role="alert">{error === "shop-name" ? "Enter a shop name between 1 and 120 characters." : "We could not create the shop. Please try again."}</p>}
          <button className="primary-button active-button" type="submit">Create shop<span aria-hidden="true">→</span></button>
        </form>
        <form action={signOutAction}><button className="quiet-button" type="submit">Sign out</button></form>
      </section>
      <p className="auth-footnote">You will become the owner of this shop. Permanent QR stations identify the shop upload entry point and grant no file access.</p>
    </main>
  );
}
