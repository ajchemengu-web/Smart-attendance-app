// The backend is the same FastAPI service in Alternative_Identifier
// that the web platform (Smart-gen.com) talks to — SmartAttendance
// is "different app, same platform" (docs/PRD.md §4).
//
// Override at build/run time, e.g.:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
// (10.0.2.2 is how the Android emulator reaches the host machine's
// localhost — see README.md.)
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
