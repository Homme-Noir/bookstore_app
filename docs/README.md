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

The **GitHub Pages** site uses Jekyll with the [Minimal](https://github.com/pages-themes/minimal) theme and custom SCSS aligned with the app’s orange accent (`#EA580C`) and warm surfaces — see [`_config.yml`](_config.yml) and [`assets/css/style.scss`](assets/css/style.scss). The published homepage is [`index.md`](index.md) (Supabase **Site URL** / **Redirect URL**). See [Adding a Jekyll theme on GitHub Pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/adding-a-theme-to-your-github-pages-site-using-jekyll).

Supabase SQL artifacts live under `backend/supabase/` (see `backend/README.md`). The Flutter app root `README.md` covers run commands and environment variables.
