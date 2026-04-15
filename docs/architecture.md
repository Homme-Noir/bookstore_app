# Personal Library Architecture

See also the [documentation index](README.md) for setup and API notes.

## Frontend

- Flutter app supports Android and Linux.
- Provider-based modules:
  - `library`: local import and catalog.
  - `reader`: progress and annotation persistence.
  - `discovery`: normalized external search.
  - `sync`: Supabase sync orchestration.
- Drift/SQLite local tables persist library items, progress, and annotations.

## Backend

- Supabase (hosted free tier) for identity, synced entities, and storage.
- FastAPI discovery service for source adapters and download preflight.

## Data Ownership

- Offline-first local storage remains the source of truth while offline.
- Sync updates are merged by deterministic conflict handlers:
  - library field-level merge with monotonic progress,
  - reading progress monotonic percentage + recency fallback,
  - annotations by `annotation_id` + version precedence + tombstones.
- Sync checkpoints/cursors are stored in secure key-value storage.
- Failed sync/download operations are queued for retry with backoff + dead-letter status.

## Security

- Row-level security policies on Supabase tables.
- Legal disclaimer gate before initiating downloads.
- Preflight checks include MIME validation, blocked extension guardrails, and max-size limits.
