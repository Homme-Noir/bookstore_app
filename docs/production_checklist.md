# Production checklist

Use this when cutting a store or enterprise release.

## CI and quality gates

- GitHub Actions **CI** (`.github/workflows/ci.yml`) runs `flutter analyze`, `flutter test`, and discovery-service compile + unit tests on every push/PR to `main`/`master`. Use **Actions → CI → Run workflow** for a manual run (`workflow_dispatch`).
- In the GitHub repo **Settings → Actions → General**, allow workflows to run (org policies sometimes disable them until you enable).
- Keep the main branch green before tagging a release.

## Flutter app

- **Dart defines for release builds** (CI/CD or local):

  ```text
  --dart-define=SUPABASE_URL=...
  --dart-define=SUPABASE_ANON_KEY=...
  --dart-define=DISCOVERY_API_BASE_URL=https://<your-discovery-host>
  ```

- **Android**
  - **applicationId** / **namespace** are **`app.personallibrary`** (see `android/app/build.gradle.kts`). Cloud auth, database, and file storage use **Supabase** when configured.
  - Release signing: run **`./scripts/create_android_release_keystore.sh`** (creates `android/upload-keystore.jks` and prints `key.properties` lines), or copy from `android/key.properties.example` if you use your own keystore.

- **iOS / macOS** (if you ship there): configure signing in Xcode, ATS, and any URL allowlists.

- **Secrets**: never commit Supabase keys or signing files; use CI secret stores and `--dart-define` or `--dart-define-from-file` as appropriate.

## Discovery service (Fly or other host)

- Deploy from `backend/discovery-service/` (Dockerfile uses **Python 3.12**).
- Set Fly secrets (from repo root), for example:

  ```bash
  export ANNAS_SECRET_KEY='...'
  ./scripts/fly_discovery_secrets.sh
  ```

  Or manually: `cd backend/discovery-service && fly secrets set ANNAS_SECRET_KEY=... -a bookstore-discovery`.

  Plain HTTP fetches to upstreams may still be blocked; the Anna adapter expects HTTPS and optional donation key for reliable HTML.

- **Preflight endpoint**: `POST /download/preflight` only allows **https** URLs by default (blocks private IPs and localhost). For local dev against `http://` hosts, set `ALLOW_HTTP_PREFLIGHT=1` on the server (never in public production unless you understand the risk).

## Supabase

- Apply `backend/supabase/schema.sql`, `rls.sql`, and `indexes.sql` to the **production** project.
- Buckets remain private; use short-lived signed URLs.
- Use a **production** anon key with RLS enforced; rotate keys if exposed.

## Before launch

- Run through legal/onboarding flows on a release build.
- Smoke-test discovery, download ingest, sync, and reader on a real device.
- Monitor logs and crash reporting if you have them wired.
