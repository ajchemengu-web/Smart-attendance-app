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
- **Navigation shell** (docs/PRD.md §7.3) — both roles share the same
  app shell shape: a top nav bar (Schedule / Intraday / Pigeonhole)
  and a bottom nav bar (Alerts / History / Profile), with
  role-specific content in each tab.
  - **Student** (`lib/screens/home/home_shell.dart`) — Schedule
    resolves the logged-in student's own
    department/course/year/semester via `GET /me`, then fetches their
    timetable via the existing
    `GET /timetable?course=&year=&semester=` that the web Timetabling
    Admin dashboard already reads; Intraday filters those same
    entries down to today's day-of-week; Profile surfaces face
    enrollment status alongside a shortcut to enroll/re-enroll.
  - **Lecturer** (`lib/screens/home/lecturer_home_shell.dart`) —
    Schedule resolves the logged-in lecturer's own profile via the
    same `GET /me`, then fetches their own timetable entries via
    `GET /timetable?lecturer_id=<their own lecturer_id>`; a timetable
    entry's lecturer is derived from the unit it references
    (Alternative_Identifier's unit_service.py), not typed onto the
    entry, so this is an ID match, not a free-text name match.
    Intraday filters the same way as the student's. Profile surfaces
    a shortcut to registering the units they teach.
  - **Pigeonhole** and **Alerts** have no backend model yet (no
    mailing/announcements system, and the classroom-camera attendance
    pipeline is still "not started" per PRD §13 Phase 2), so both
    roles see an honest placeholder rather than fake data. **History**
    is likewise a placeholder, but its copy differs per role per the
    PRD table: a student's is framed as personal attendance history,
    a lecturer's as attendance PDFs per class.
- **Register units you teach** (`lib/screens/
  unit_registration_screen.dart`, LECTURER, reached from the Profile
  tab or the icon next to sign-out) — lists every unit the
  Timetabling Admin has created and lets a lecturer claim
  (`PATCH /units/{id}/claim`) or release (`PATCH /units/{id}/unclaim`)
  the ones they teach. A unit already claimed by someone else shows
  as unavailable rather than being silently overwritten. This claim,
  not a name typed onto a timetable row, is what populates the
  lecturer's Schedule tab above — a lecturer self-registers once per
  unit rather than trusting the Timetabling Admin to spell their name
  exactly right on every entry.
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

## Deployment (web build)

The web build (`flutter build web`) is a static site, so it deploys
two ways:

- **GitHub Pages** (`.github/workflows/deploy-web.yml`) — builds on
  every push to `main` and deploys to `https://<owner>.github.io/
  <repo>/`, so it passes `--base-href=/<repo>/`.
- **Vercel** (`vercel.json` + `vercel-build.sh`) — same platform
  `Smart-gen.com` already deploys on. Vercel has no native Flutter
  builder, so `vercel-build.sh` downloads a pinned Flutter SDK
  (matching `pubspec.yaml`'s `sdk: ^3.13.3` constraint) before
  building; `vercel.json` points Vercel at that script and at
  `build/web` as the output directory. Served from the project's own
  domain root, so — unlike the GitHub Pages build — no `--base-href`
  override is passed.

  To connect this repo: in the Vercel dashboard, **Add New… →
  Project**, import this repository, and set the **Root Directory**
  if this app doesn't live at the repo root. Framework Preset can be
  left as "Other" — `vercel.json` supplies the build/install/output
  settings. Then add an **API_BASE_URL** environment variable
  (Project Settings → Environment Variables) pointing at the FastAPI
  backend's reachable URL, same convention as the `API_BASE_URL`
  repo Actions variable the GitHub Pages/APK workflows already use —
  see `lib/config.dart`. Without it, the deployed build falls back to
  `http://localhost:8000`, which only works from the machine actually
  running the backend.
