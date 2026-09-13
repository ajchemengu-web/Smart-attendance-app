import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const SmartAttendanceApp());
}

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Gen — SmartAttendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F7CFF)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
