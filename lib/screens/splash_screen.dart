import 'package:flutter/material.dart';

import '../services/session_store.dart';
import 'home/home_shell.dart';
import 'home/lecturer_home_shell.dart';
import 'login_screen.dart';

/// Decides where to land based on whether a session is already
/// stored on-device — mirrors the web platform's proxy.ts bouncing
/// an already-logged-in visitor away from /login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final sessionStore = SessionStore();
    final token = await sessionStore.token;

    if (token == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final role = await sessionStore.role;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => role == 'LECTURER'
            ? const LecturerHomeShell()
            : const HomeShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face_retouching_natural,
                color: colorScheme.onPrimaryContainer,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
