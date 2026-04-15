/**
 * Supabase JS client for Node scripts (migrations helpers, admin tasks).
 * The Flutter app uses supabase_flutter with the same SUPABASE_URL / SUPABASE_ANON_KEY.
 *
 * Usage:
 *   export SUPABASE_URL=https://xxxx.supabase.co
 *   export SUPABASE_ANON_KEY=eyJ...
 *   node scripts/supabase/example-query.mjs
 *
 * Or load from a local env file (not committed):
 *   set -a && source .env.dev && node ...
 */
import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL ?? "";
const anonKey = process.env.SUPABASE_ANON_KEY ?? "";

if (!url || !anonKey) {
  throw new Error(
    "Set SUPABASE_URL and SUPABASE_ANON_KEY (see .env.template in repo root).",
  );
}

export const supabase = createClient(url, anonKey);
