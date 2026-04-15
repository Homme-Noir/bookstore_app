# Documentation

| Document | Purpose |
|----------|---------|
| [architecture.md](architecture.md) | High-level system design, data ownership, security. |
| [developer_guide.md](developer_guide.md) | Local setup, project layout, and how to extend the app. |
| [api_documentation.md](api_documentation.md) | Supabase data access, discovery HTTP API, and client responsibilities. |
| [production_checklist.md](production_checklist.md) | Release signing, secrets, CI, and operations. |
| [release_and_rollback.md](release_and_rollback.md) | Release process and rollback expectations. |
| [packaging_profile.md](packaging_profile.md) | Build profiles and packaging notes. |
| [two_device_validation.md](two_device_validation.md) | Multi-device sync validation scenarios. |

The static file [`index.html`](index.html) is the **GitHub Pages** landing page used as Supabase **Site URL** / **Redirect URL** for email confirmation (see repo Settings → Pages). The empty [`.nojekyll`](.nojekyll) file disables Jekyll so this HTML is served as-is.

Supabase SQL artifacts live under `backend/supabase/` (see `backend/README.md`). The Flutter app root `README.md` covers run commands and environment variables.
