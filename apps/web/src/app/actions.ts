"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

async function requireUser() {
  const supabase = await createClient();
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) redirect("/login");
  return { supabase, user };
}

export async function createShopAction(formData: FormData) {
  const { supabase } = await requireUser();
  const name = String(formData.get("name") ?? "").trim();
  if (name.length < 1 || name.length > 120) redirect("/onboarding?error=shop-name");

  const { error } = await supabase.rpc("create_shop_with_owner", { p_name: name });
  if (error) redirect("/onboarding?error=shop-create");
  revalidatePath("/");
  redirect("/");
}

export async function createQrStationAction(formData: FormData) {
  const { supabase, user } = await requireUser();
  const shopId = String(formData.get("shop_id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  if (!/^[0-9a-f-]{36}$/i.test(shopId) || name.length < 1 || name.length > 80) {
    redirect("/?error=station-input");
  }

  const { error } = await supabase.from("qr_stations").insert({
    shop_id: shopId,
    name,
    created_by: user.id,
  });
  if (error) redirect("/?error=station-create");
  revalidatePath("/");
  redirect("/");
}

export async function updateQrStationAction(formData: FormData) {
  const { supabase } = await requireUser();
  const shopId = String(formData.get("shop_id") ?? "");
  const stationId = String(formData.get("station_id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const isActive = String(formData.get("is_active") ?? "") === "true";
  if (!/^[0-9a-f-]{36}$/i.test(shopId) || !/^[0-9a-f-]{36}$/i.test(stationId) || name.length < 1 || name.length > 80) {
    redirect("/?error=station-input");
  }

  const { error } = await supabase.from("qr_stations")
    .update({ name, is_active: isActive })
    .eq("id", stationId)
    .eq("shop_id", shopId);
  if (error) redirect("/?error=station-update");
  revalidatePath("/");
  redirect("/");
}

export async function updateShopSettingsAction(formData: FormData) {
  const { supabase } = await requireUser();
  const shopId = String(formData.get("shop_id") ?? "");
  const settings = {
    max_file_size_bytes: Number(formData.get("max_file_size_mb")) * 1048576,
    max_files_per_session: Number(formData.get("max_files_per_session")),
    max_total_bytes_per_session: Number(formData.get("max_total_mb_per_session")) * 1048576,
    session_ttl_hours: Number(formData.get("session_ttl_hours")),
  };
  if (!/^[0-9a-f-]{36}$/i.test(shopId) || Object.values(settings).some((value) => !Number.isSafeInteger(value))) {
    redirect("/?error=settings-input");
  }

  const { error } = await supabase.from("shop_settings").update(settings).eq("shop_id", shopId);
  if (error) redirect("/?error=settings-update");
  revalidatePath("/");
  redirect("/");
}

export async function signOutAction() {
  const { supabase } = await requireUser();
  await supabase.auth.signOut();
  redirect("/login");
}
