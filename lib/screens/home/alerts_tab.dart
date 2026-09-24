import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.notifications_none,
      title: 'Alerts',
      explanation:
          'Attendance notifications, class reminders, and your running '
          'attendance % will show up here once the classroom-camera '
          'attendance pipeline is built.',
    );
  }
}
