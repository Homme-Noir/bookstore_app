# Personal Library Sync App

A Flutter personal library application for Linux and Android with:

- local EPUB/PDF import
- reading progress + annotation persistence
- discovery search adapters
- Supabase-oriented hosted sync scaffolding
- Drift/SQLite local persistence + secure sync state storage
- retry queue for failed sync/download jobs

## Repository layout

| Path | Role |
|------|------|
| `lib/` | Flutter app: `core/`, `features/` (library, reader, discovery, sync), `services/`, `screens/` |
| `backend/supabase/` | Postgres schema, RLS, indexes applied to your Supabase project |
| `backend/discovery-service/` | FastAPI search + download preflight (deploy separately, e.g. Fly.io) |
| `docs/` | Architecture, developer guide, API notes, production checklists |
| `scripts/` | Supabase JS helpers (`scripts/supabase/`), release/signing helpers |

The Dart package name is **`personal_library`** (see `pubspec.yaml`).

## Documentation

- **Index:** [docs/README.md](docs/README.md) — links to architecture, developer guide, API/integration notes, and ops runbooks.
- **Backend SQL + discovery deploy:** [backend/README.md](backend/README.md).

## Run App

**Recommended (local secrets file, not committed):** copy `.env.dev.template` → **`.env.local`**, fill **`SUPABASE_ANON_KEY`** (JWT from Supabase → API, not the `sb_publishable_…` string for this Flutter app), then:

```bash
flutter pub get
flutter run --dart-define-from-file=.env.local
```

Discovery uses **Open Library only** by default. Anna is merged only when the Fly app has **`ANNAS_SECRET_KEY`** set **and** you opt in with **`DISCOVERY_INCLUDE_ANNA=true`** (e.g. add to `.env.local` or `--dart-define=DISCOVERY_INCLUDE_ANNA=true`).

**Or** pass defines explicitly:

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=SUPABASE_URL=https://buzqfnaodqxuusgisnio.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt> \
  --dart-define=DISCOVERY_API_BASE_URL=https://bookstore-discovery.fly.dev
```

Discovery defaults to **`https://bookstore-discovery.fly.dev`** if you omit `DISCOVERY_API_BASE_URL`. Override for a local API, e.g. `--dart-define=DISCOVERY_API_BASE_URL=http://127.0.0.1:8000`. To use **only** Open Library offline, pass an empty value (tooling-dependent) or change the default in `lib/main.dart`.

Use your **Fly.io** URL on real devices (Android/iPhone), not `localhost`. See `backend/README.md` → **Discovery Service (Fly.io)**.

If Supabase variables are not provided, the app runs with mock authentication and local-only features.

## Backend Services

See `backend/README.md` for Supabase schema + discovery service notes.

### Supabase JS (Node scripts)

The dashboard flow (`npm install @supabase/supabase-js`) is already reflected in the repo root **`package.json`**. After cloning:

```bash
npm install
```

Shared client and a tiny sanity script live under **`scripts/supabase/`** (`client.mjs`, `example-query.mjs`). Set **`SUPABASE_URL`** and **`SUPABASE_ANON_KEY`** in the environment (same values as Flutter `--dart-define`s), then:

```bash
node scripts/supabase/example-query.mjs
```

**Agent skills:** Supabase’s optional skills were installed with `npx skills add supabase/agent-skills -y` into **`.agents/skills/`** (and linked for Cursor). Commit or ignore that folder per your team policy.

Your **real** project URL and anon key only exist in **your** Supabase project settings—they are not in git (only `.env*.template` placeholders), so they must be supplied by you when running the app or scripts.

## Environment Profiles

- `APP_ENV=dev`: local test setup and optional discovery service.
- `APP_ENV=staging`: pre-production Supabase project.
- `APP_ENV=prod`: production Supabase project and locked policies.

Use `.env.dev.template`, `.env.staging.template`, and `.env.prod.template` as references.

## Production

- See **[docs/production_checklist.md](docs/production_checklist.md)** for release signing, Supabase, discovery service secrets, and CI expectations.
- **GitHub Actions** runs `flutter analyze`, tests, and discovery-service checks on pushes/PRs to `main` or `master`.
- **Scripts:** `scripts/create_android_release_keystore.sh` (Play signing), `scripts/fly_discovery_secrets.sh` (Fly env for discovery). `.env.prod.template` lists dart-define variables for prod builds.

## Sync and Operations

- Sync screen exposes schema guard status and retry/dead-letter job monitoring.
- Backup export is available from Sync tab (`Export local backup`).
- On first launch, onboarding verifies legal disclaimer acceptance and Supabase readiness.

