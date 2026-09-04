# Daymark

Offline-first personal bucket-list and memory-tracking app. Flutter, BLoC/Cubit, Drift + SQLite, GoRouter, Material 3.

## What's implemented (Phases 1–5 from the spec)

- **Foundation**: theme (light/dark, indigo/violet accent), GoRouter with a `StatefulShellRoute` bottom nav (Home / Bucket List / Memories), consistent spacing/typography tokens.
- **Database**: Drift schema for `BucketListItems`, `Links`, `Media`, `Memories`, with DAOs and repositories (`BucketListRepository`, `MediaRepository`, `MemoryRepository`) sitting between BLoC and the database.
- **Bucket List**: list with search (debounced), All/To Do/Completed tabs, category+priority filter sheet, sort menu, item cards with color accent, add/edit/delete, completion toggle, empty states.
- **Item Details**: full item view, links (open externally), completion toggle with the "You lived it ✨ / Add memory" prompt, delete with confirmation.
- **Home**: greeting, progress card, stat tiles (only shown when there's data), recently completed, high-priority "must experience" list — all driven by real Drift queries, no hardcoded numbers.
- **Settings**: appearance/data/cloud-sync-placeholder/about sections (export/import and theme switching are stubbed as tap targets, not wired up yet).

## Not yet built

- Media (photo/video) picking and storage, and the Memories notes/journal entry flow — the schema and `MediaRepository`/`MemoryRepository` are ready for it.
- Country → state/region cascading pickers (location fields are currently free-text).
- Data export/import, theme switching in Settings, onboarding, sample/seed data, and general polish (animations, skeleton loaders).

## Setup

1. Copy this folder into a fresh `flutter create daymark` project (or `flutter create .` inside this folder) so you get the `android/`, `ios/`, etc. platform folders — only `lib/` and `pubspec.yaml` are included here.
2. `flutter pub get`
3. Generate Drift's code (`*.g.dart` files aren't included — they're generated, not hand-written):
   ```
   dart run build_runner build --delete-conflicting-outputs
   ```
4. `flutter run`

## Notes

- IDs are UUID strings (not autoincrement ints) so records stay stable once cloud sync is added later — no rewrite needed for that part.
- No domain layer, use-cases, or base-class abstractions, per the spec — Cubits talk straight to repositories, repositories talk straight to Drift.
