# Packaging and Rollback Profile

## Android

- Build command: `flutter build apk --release`.
- Signing: configure keystore via `android/key.properties`.
- Artifact: `build/app/outputs/flutter-apk/app-release.apk`.

## Linux

- Build command: `flutter build linux --release`.
- Package output: `build/linux/x64/release/bundle/`.
- Optional wrapping: AppImage/deb via downstream CI job.

## Compatibility Matrix

| App version | Schema version | Compatible |
| --- | --- | --- |
| v1.0.0 | v1.0.0 | Yes |
| v1.1.0 | v1.0.0 | Read-only fallback |

## Rollback

1. Keep previous release artifact for Android/Linux.
2. Verify `schema_migrations` contains target rollback-compatible version.
3. Restore local backup snapshot if on-device state is corrupted.

