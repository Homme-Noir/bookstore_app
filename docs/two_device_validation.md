# Two-Device Validation Matrix (Android + Linux)

## Preconditions

- Same Supabase project and user account on both devices.
- Both devices use same app build revision.
- Network toggle access available (for offline/online scenarios).

## Test Cases

1. **Auth parity**
   - Login on Android and Linux with same account.
   - Confirm both show non-empty library shell and sync ready state.
2. **Import then resume**
   - Import EPUB/PDF on Android.
   - Sync on Android, then sync on Linux.
   - Open item on Linux and verify metadata + progress baseline.
3. **Progress reconciliation**
   - Advance to 60% on Linux, sync.
   - Advance to 45% on Android while offline, reconnect, sync.
   - Expected: monotonic rule keeps 60% unless Android timestamp is newer and within threshold.
4. **Annotation lifecycle**
   - Create annotation on Android, sync to Linux.
   - Delete annotation on Linux and undo once.
   - Delete again and sync: annotation should remain hidden (tombstoned) on both.
5. **Retry/dead-letter behavior**
   - Force a blocked download URL.
   - Confirm retry job appears in queue with attempts and error reason.
   - After repeated failures, verify transition to `dead_letter`.

## Evidence Capture

- Save screenshots for each case with timestamp.
- Export local backup JSON from Sync tab on both devices.
- Record failures in release ledger with reproduction steps.

