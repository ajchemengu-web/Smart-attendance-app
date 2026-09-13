import 'package:flutter/material.dart';

import '../services/session_store.dart';
import 'login_screen.dart';
import 'schedule_screen.dart';

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
    final token = await SessionStore().token;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            token == null ? const LoginScreen() : const ScheduleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
