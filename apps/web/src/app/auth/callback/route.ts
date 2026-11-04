import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");
  const requestedNext = request.nextUrl.searchParams.get("next") ?? "/";
  const nextUrl = new URL(requestedNext, request.url);
  const next = nextUrl.origin === request.nextUrl.origin ? nextUrl : new URL("/", request.url);
  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(next);
  }
  return NextResponse.redirect(new URL("/login?error=confirmation", request.url));
}
