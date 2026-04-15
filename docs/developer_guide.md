# Developer Guide

## Overview

This repository is a **personal library** Flutter application: offline-first local storage (Drift/SQLite), optional **Supabase** sync, book **discovery** via a small FastAPI service or direct Open Library, and an **EPUB/PDF** reader with progress and annotations.

The Dart package name is **`personal_library`** (`pubspec.yaml`); the product is branded **Personal Library** in the UI.

## Tech stack

- **Flutter / Dart** (see `pubspec.yaml` for SDK bounds)
- **Provider** for app-wide state
- **Drift** + **sqlite3** for local catalog, reading state, annotations, and retry jobs
- **flutter_secure_storage** for sync checkpoints and other sensitive key-value data
- **supabase_flutter** when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are supplied at build/run time
- **FastAPI** discovery microservice under `backend/discovery-service/` (optional; can use bundled adapters instead)

## Repository layout

```
lib/
  core/                 # Cross-cutting: DB, secure storage, telemetry
  features/
    discovery/          # Search adapters, ingest, UI
    library/            # Local catalog
    reader/             # Progress + annotations
    sync/               # Supabase sync orchestration, retry queue, conflicts
  providers/            # AppProvider, ProfileProvider (shell state)
  screens/              # Navigation shell, auth, onboarding, profile
  services/             # Auth, Open Library, Supabase sync, sync state
  theme/
backend/
  discovery-service/    # FastAPI search + download preflight
  supabase/             # schema.sql, rls.sql, indexes.sql
docs/                   # Architecture, ops, this guide
scripts/                # Supabase JS helpers, release helpers
```

Platform folders (`android/`, `ios/`, `linux/`, …) follow standard Flutter layout.

## Configuration

1. Copy `.env.dev.template` to **`.env.local`** (gitignored) and set secrets such as `SUPABASE_ANON_KEY`.
2. Run with `--dart-define-from-file=.env.local` as described in the root `README.md`.
3. For the discovery API on a physical device, use a **public** base URL (for example Fly.io), not `localhost`.

If Supabase variables are omitted, the app uses **mock authentication** and local-only features; see `AuthService`.

## Adding a feature

- **New screen:** add under `lib/screens/` or under the relevant `features/*/presentation/screens/` folder, register a route in `lib/main.dart` if needed.
- **New provider:** create a `ChangeNotifier` (or existing pattern), register it in `MyApp`’s `MultiProvider` in `lib/main.dart`.
- **New persistence:** extend `LocalDatabase` and repositories under `features/*/data/`; mirror server shape in `backend/supabase/` when syncing.

## Testing and analysis

```bash
flutter pub get
flutter analyze
flutter test
```

The GitHub Actions workflow in `.github/workflows/ci.yml` runs analyze, tests, and discovery-service checks.

## Related reading

- [architecture.md](architecture.md) — data flow and conflict handling
- [api_documentation.md](api_documentation.md) — Supabase and HTTP APIs
- [production_checklist.md](production_checklist.md) — shipping builds
