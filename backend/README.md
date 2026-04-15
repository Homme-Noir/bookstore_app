# Backend Integration Notes

This repository uses:

- Supabase (hosted) for auth, Postgres data, storage, and realtime sync.
- FastAPI discovery microservice for source adapters and download preflight checks.

## Supabase Setup

**This repo targets project ref `buzqfnaodqxuusgisnio`** (`https://buzqfnaodqxuusgisnio.supabase.co`). When you fork or clone for your own project, replace this with **your** Supabase URL and ref from the dashboard. Use the **anon JWT** (`eyJ…`) in the Flutter app and JS scripts—not the `sb_publishable_…` key unless your tooling explicitly requires it.

**CLI:** `supabase login` → `supabase init` (if needed) → `supabase link --project-ref buzqfnaodqxuusgisnio`. Use the **database password** from the dashboard only in your local Supabase CLI / `psql` session—never commit it.

1. Create a Supabase project.
2. Set Flutter runtime defines:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Apply SQL schema in `backend/supabase/schema.sql`.
4. Enable row-level security and policies in `backend/supabase/rls.sql`.
   - If the database already existed before FK indexes were added, also run `backend/supabase/indexes.sql` once (safe to re-run).
5. Create storage buckets:
   - `user-books` (private)
   - `user-covers` (private)
6. Insert migration marker:
   - `insert into schema_migrations(version) values ('v1.0.0');`
7. Verify app schema guard by opening Sync tab after login.

### Storage policy baseline

- Buckets must stay private.
- Signed URLs should be issued with short TTL.
- Limit object listing to owner-scoped paths.

## Discovery Service (Fly.io)

The FastAPI app in `backend/discovery-service/` powers search (Open Library + Anna adapter) and `/download/preflight`. For **phone** builds, host it on a public URL and set:

`DISCOVERY_API_BASE_URL=https://<your-app>.fly.dev`

### Deploy on Fly.io

Prerequisites: [Fly CLI](https://fly.io/docs/hands-on/install-flyctl/) installed and logged in (`fly auth login`).

From the service directory:

```bash
cd backend/discovery-service
```

1. **Create the Fly app once** (required before `fly deploy`; otherwise you get `app not found`):

   ```bash
   fly apps create bookstore-discovery
   ```

   If the name is taken, pick a unique name, set `app = "that-name"` in `fly.toml`, then `fly apps create that-name`.

2. **Billing:** Fly may require a **payment method** or **prepaid credit** on your org before new apps can be created. If `fly apps create` asks for billing, open the Fly dashboard → **Organization** → **Billing**, add a card or credit, then retry.

3. Deploy:

```bash
fly deploy
```

4. Note the app URL (e.g. `https://bookstore-discovery.fly.dev`). Check health:

```bash
curl https://<your-app>.fly.dev/health
```

5. In Flutter, run or build with:

```bash
flutter run --dart-define=DISCOVERY_API_BASE_URL=https://<your-app>.fly.dev \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

`fly.toml` uses `min_machines_running = 0` so idle apps can **scale to zero** (first request may be slower). Raise `min_machines_running` or sizing in `fly.toml` if you need steadier latency.

Secrets (Anna search): `fly secrets set ANNAS_SECRET_KEY=...` — do not commit secrets to the repo. **Without that key, `/search` only merges Open Library** even if `include_anna=true`. After you set the key, Flutter must use **`DISCOVERY_INCLUDE_ANNA=true`** if you want the client to request Anna (default is Open Library only).

Preflight (`POST /download/preflight`) allows **https** URLs only by default (blocks private IPs / localhost). For local dev against `http://` hosts, set `ALLOW_HTTP_PREFLIGHT=1` on the server only.

See `docs/production_checklist.md` in the repo root for a full production checklist.

Anna’s Archive tooling reference (donation API key / CLI): [iosifache/annas-mcp](https://github.com/iosifache/annas-mcp) — same env names as our discovery service (`ANNAS_SECRET_KEY`, optional `ANNAS_BASE_URL`). Official FAQ on APIs and mirrors: [annas-archive FAQ](https://annas-archive.gl/faq).
