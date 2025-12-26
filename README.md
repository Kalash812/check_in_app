# Offline Task & Check-in App

Flutter app with Firebase-ready auth, Hive-backed offline cache, and check-ins that sync when online. Built with Cubit (Bloc) and clean architecture layers.

## Features
- Login/Logout with persisted session (Firebase-ready; offline fallback), role-based Admin/Member access.
- Task list with lazy loading, filter by status, sort by due date/priority, sync status badges, detail screen with status updates.
- Check-in form (notes >= 10 chars, category, optional photo, mandatory location), creates locally first and syncs when online; per-item sync states (pending/synced/failed).
- Admin task management: create/edit tasks, assign seeded users, offline-friendly.
- Offline-first: Hive cache for tasks/check-ins/session; connectivity banner and background sync on reconnect.

Demo credentials (offline mode): `admin@checkin.dev` / `member@checkin.dev` with `password123`.

## Architecture
- **domain/** models, enums, repositories, usecases.
- **data/** local Hive storage & data sources, Firestore/Firebase-ready remotes, repository implementations, seed data.
- **viewmodel/** Cubits for auth, tasks, task detail, check-in, connectivity, sync.
- **ui/** screens (login, task list/detail, task form, check-in sheet), theming.
- **core/** config, failure/result helpers, theming, utils.

## Setup
1. Ensure Flutter SDK is installed.
2. Install dependencies: `flutter pub get`
3. Run app: `flutter run`
4. Tests: `flutter test`

## Firebase configuration (placeholders are checked in)
- Replace `lib/core/config/firebase_options.dart` with your project values (via `flutterfire configure` or manual copy).
- Toggle `AppConfig.enableFirebaseAuth` / `AppConfig.enableFirebaseRemote` in `lib/core/config/app_config.dart` to `true` after adding credentials.
- Firestore collections expected: `tasks` and `checkins` (schema mirrors the model `toJson`).

## Offline & Sync behavior
- Local persistence via Hive boxes for tasks, check-ins, and session.
- Check-ins created offline are saved with `pending` (remote on) or `localOnly` (remote off); sync runs on connectivity regain and via manual refresh (client wins on conflicts).
- Tasks created/edited offline are marked `pending` and synced when remote is enabled; otherwise remain `localOnly`.
- Location permissions are required for submitting check-ins; camera permission is needed for photo attachments.

## Testing & CI
- Unit/Cubit tests: auth/login states, task filtering/sorting, check-in form state.
- Repository tests: task/check-in persistence + sync flow.
- Widget test: login form validation.
- CI: `.github/workflows/ci.yml` runs `flutter test` on push/PR.

## Demo evidence
- Add a short screen recording or screenshots under `docs/` or link to your drive when ready. Include login, task list filtering, check-in submission (offline then synced).
