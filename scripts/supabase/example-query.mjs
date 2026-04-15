/**
 * Sanity check: Supabase client loads; session is usually null until you sign in.
 * Run from repo root with SUPABASE_URL and SUPABASE_ANON_KEY set.
 */
import { supabase } from "./client.mjs";

const {
  data: { session },
  error,
} = await supabase.auth.getSession();

if (error) {
  console.error(error.message);
  process.exit(1);
}

console.log("Supabase JS client OK. Has session:", !!session);
