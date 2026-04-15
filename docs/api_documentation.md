# API and integration surface

This app talks to two kinds of backends: **Supabase** (Postgres, Auth, optional Storage) and the optional **discovery** HTTP service. Everything else runs locally in Dart.

## Supabase (when configured)

The Flutter client uses **supabase_flutter**, which exposes Supabase **Auth** and **PostgREST**-backed tables. Schema source of truth: `backend/supabase/schema.sql`; policies: `backend/supabase/rls.sql`.

### Authentication

- Real sign-in/sign-up when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set at compile time.
- If those are missing, `AuthService` falls back to **mock users** for local development (see `lib/services/auth_service.dart`).

### Data tables (summary)

| Area | Tables (see schema for columns) |
|------|----------------------------------|
| Profile | `profiles` |
| Library | `library_items`, `book_files` |
| Reader | `reading_progress`, `annotations` |
| Ops | `schema_migrations`, `sync_events` |

Row-level security is required for any client-facing access; do not bypass RLS with service keys in the mobile app.

### Client responsibilities

`SupabaseSyncService` upserts and merges remote rows with local models using `ConflictResolver`. File paths remain device-local; remote rows never overwrite local filesystem paths.

## Discovery microservice (optional)

Default base URL is configurable via `DISCOVERY_API_BASE_URL` (see root `README.md`). Implementation: `backend/discovery-service/app/main.py`.

### `GET /health`

Returns `{"status": "ok"}` for load balancers and smoke checks.

### `GET /search`

- **Query parameters:** `query` or `q` (search string), optional `include_anna` (server also needs Anna credentials via env).
- **Behavior:** merges **Open Library** results with optional **Anna’s Archive** when `ANNAS_SECRET_KEY` or `ANNAS_API_KEY` is set on the server.
- **Response:** JSON matching `SearchResponse` in `backend/discovery-service/app/schemas.py`.

### `POST /download/preflight`

- **Body:** JSON with a `url` field (`DownloadPreflightRequest`).
- **Behavior:** validates URL safety (`preflight_url` module), performs a `HEAD` request, checks MIME type and size hints.
- **Response:** `allowed`, optional `reason`, `mime_type`, `content_length` (`DownloadPreflightResponse`).

For local HTTP targets, the server may require `ALLOW_HTTP_PREFLIGHT=1` (development only).

## External HTTP (client-side adapters)

When the discovery API base URL is **empty**, the app can use **Open Library** and optional **Anna** adapters directly from Dart (`lib/features/discovery/data/`). Rate limits and terms of upstream APIs apply.

## Local-only APIs

There is **no** separate REST server inside the Flutter process. Local state is accessed through repositories (`LocalLibraryRepository`, `LocalReaderRepository`, `SyncRetryRepository`) backed by Drift/SQLite.
