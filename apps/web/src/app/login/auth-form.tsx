"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export function AuthForm({ mode }: { mode: "login" | "signup" }) {
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [busy, setBusy] = useState(false);
  const router = useRouter();
  const isSignup = mode === "signup";

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setNotice("");
    setBusy(true);
    const form = new FormData(event.currentTarget);
    const email = String(form.get("email") ?? "").trim();
    const password = String(form.get("password") ?? "");
    const supabase = createClient();

    if (isSignup) {
      const { data, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: { emailRedirectTo: `${window.location.origin}/auth/callback?next=/onboarding` },
      });
      setBusy(false);
      if (authError) return setError(authError.message);
      if (!data.session) return setNotice("Check your email to confirm your account, then return here to sign in.");
    } else {
      const { error: authError } = await supabase.auth.signInWithPassword({ email, password });
      setBusy(false);
      if (authError) return setError("Email or password was not accepted.");
    }

    router.replace("/");
    router.refresh();
  }

  return (
    <main className="auth-page">
      <Link className="brand auth-brand" href="/" aria-label="DROPQR Studio">
        <span className="brand-mark" aria-hidden="true">D</span>
        <span className="brand-name">dropqr<span>studio</span></span>
      </Link>
      <section className="auth-card" aria-labelledby="auth-title">
        <p className="eyebrow">SECURE SHOP WORKSPACE</p>
        <h1 id="auth-title">{isSignup ? "Create your account" : "Welcome back"}</h1>
        <p className="auth-intro">{isSignup ? "Sign up with email and password to set up your shop." : "Sign in to manage your shop and its QR stations."}</p>
        <form className="form-stack" onSubmit={handleSubmit}>
          <label>Email address<input name="email" type="email" autoComplete="email" required maxLength={254} /></label>
          <label>Password<input name="password" type="password" autoComplete={isSignup ? "new-password" : "current-password"} required minLength={8} maxLength={128} /></label>
          {error && <p className="form-message error" role="alert">{error}</p>}
          {notice && <p className="form-message success" role="status">{notice}</p>}
          <button className="primary-button active-button" disabled={busy} type="submit">{busy ? "Please wait…" : isSignup ? "Create account" : "Sign in"}<span aria-hidden="true">→</span></button>
        </form>
        <p className="auth-switch">{isSignup ? "Already have an account?" : "New to DROPQR Studio?"} <Link href={isSignup ? "/login" : "/signup"}>{isSignup ? "Sign in" : "Create an account"}</Link></p>
      </section>
      <p className="auth-footnote">Customer upload sessions will not require an account.</p>
    </main>
  );
}
