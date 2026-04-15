# Release and Rollback Guide

## Android Release

1. Build:
   - `flutter build apk --release`
2. Verify login, import, reader progress save, and sync status screen.
3. Tag release commit and archive APK.

## Linux Release

1. Build:
   - `flutter build linux --release`
2. Smoke test import and local reading state.
3. Package artifact for distribution.

## Rollback Strategy

- Keep previous stable build artifacts for Android/Linux.
- If new release breaks sync, disable sync trigger in UI and publish hotfix.
- For backend regressions:
  - revert discovery service image tag,
  - rollback Supabase migration to previous version,
  - re-enable clients after health checks pass.

## Migration Recovery Guide

1. Put client releases on hold and keep current app in read-only mode.
2. Confirm `schema_migrations` values in Supabase and compare with release target.
3. Roll back SQL changes in reverse order of migration application.
4. Re-run Sync screen schema guard in staging user account.
5. Restore client traffic only after smoke sync/import tests pass.

## Recovery Checks

- Confirm no data loss in local SQLite database.
- Validate Supabase auth/session issuance.
- Validate `/health` and `/search` endpoints on discovery service.
- Validate backup workflow:
  - export JSON snapshot from Sync tab,
  - verify backup integrity,
  - import backup and re-check library/progress/annotations.
