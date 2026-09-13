import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_store.dart';
import 'lecturer_schedule_screen.dart';
import 'schedule_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  bool _submitting = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await _apiClient.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result.role != 'STUDENT' && result.role != 'LECTURER') {
        setState(() {
          _error =
              'This account uses the Smart Gen web dashboards, not this app.';
        });
        return;
      }

      await _sessionStore.save(result);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => result.role == 'LECTURER'
              ? const LecturerScheduleScreen()
              : const ScheduleScreen(),
        ),
      );
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Gen — SmartAttendance')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign in with your student or lecturer credentials.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSubmitted: (_) => _submitting ? null : _handleLogin(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _handleLogin,
              child: Text(_submitting ? 'Signing in…' : 'Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
