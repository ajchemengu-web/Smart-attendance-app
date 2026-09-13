# Smart Gen — SmartAttendance

The student/lecturer companion app for Smart Gen (docs/PRD.md §4, §6,
Phase 2) — "different app, same platform" as the web dashboards in
`Smart-gen.com`: same login surface's backend, same FastAPI service
(`Alternative_Identifier`), just a Flutter client instead of Next.js.

## What's here so far

- **Login** (`lib/screens/login_screen.dart`) — signs in against the
  same `POST /login` every other Smart Gen surface uses. STUDENT and
  LECTURER accounts proceed past sign-in to their own screen; any
  other role (Guard, any Admin tier) is told to use the web
  dashboards instead — this app isn't a second door into those.
- **My Schedule** (`lib/screens/schedule_screen.dart`, STUDENT) —
  resolves the logged-in student's own course/year via
  `GET /me` (Alternative_Identifier commit cb81fec), then fetches
  their timetable via the existing `GET /timetable?course=&year=`
  that the web Timetabling Admin dashboard already reads. Read-only,
  same as a student's own view should be.
- **My Units** (`lib/screens/lecturer_schedule_screen.dart`,
  LECTURER) — resolves the logged-in lecturer's own profile via the
  same `GET /me` (Alternative_Identifier commit 13ace57 added the
  `lecturers` table + branch in `/me` for this), then fetches their
  own timetable entries via `GET /timetable?facilitator=<their full
  name>`. This is a free-text match against
  `timetable_entries.facilitator`, not a foreign key (same
  lightweight style as course/year/department) — an entry only shows
  up here if the Timetabling Admin typed this lecturer's name into it
  exactly as registered on the web platform's Lecturer Profiles
  section (Original Admin dashboard).
- The access token from login is kept in the platform
  keystore/keychain via `flutter_secure_storage`
  (`lib/services/session_store.dart`) — never `SharedPreferences` —
  mirroring how the web platform never lets the access_token reach
  the browser directly.

## Explicitly out of scope (for now)

- **Classroom-camera attendance capture itself.** This app reads
  timetable data; it does not run recognition. The actual
  "classroom camera sees a student, logs them present" pipeline is
  backend/hardware work (the SmartAccess checkpoint pipeline's
  counterpart for classrooms) that hasn't been built — there's no
  classroom camera hardware in this environment to build and verify
  it against. The camera **registry** (metadata: which classrooms
  have a camera, its status) already exists
  (`Alternative_Identifier`'s `/cameras` endpoints, camera_type
  `CLASSROOM`) — wiring an actual live feed to it is future work.
- **Platform builds.** This sandbox has no Android SDK, no Chrome,
  and no Linux GTK dev libs (`flutter doctor` shows all three
  missing) — so nothing here has been run on a device or emulator.
  Verified instead with `flutter analyze` (no issues) and
  `flutter test` (the login screen's widget test passes). Build and
  device-test this on a machine with the Android/iOS toolchain
  before shipping it.

## Configuration

Points at the same backend as the web platform — override the
default at build/run time:

```bash
# Android emulator (10.0.2.2 reaches the host machine's localhost):
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# iOS simulator / physical device on the same network as the backend:
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000
```

See `lib/config.dart`.

## Development

```bash
flutter pub get
flutter analyze
flutter test
```
