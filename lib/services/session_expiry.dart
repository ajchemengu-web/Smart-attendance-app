import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import 'session_store.dart';

/// Mirrors the web platform's handleUnauthorized() (Smart-gen.com's
/// src/lib/handleUnauthorized.ts): a 401 from the backend on an
/// otherwise still-present session means the backend no longer
/// honors this access_token (rotated JWT_SECRET, revoked token,
/// expiry). Clear it from secure storage before returning to login —
/// otherwise the splash screen finds the same dead token on next
/// launch and bounces straight back here, 401-ing again.
Future<void> handleUnauthorized(BuildContext context) async {
  await SessionStore().clear();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
