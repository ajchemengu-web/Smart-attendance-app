import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

/// Lecturers don't get the student "you attended"/"you missed a
/// class" queue — Alternative_Identifier's GET /me/notifications is
/// STUDENT-only, since attendance_service.py only ever writes a
/// notification for the students expected in a session, never the
/// lecturer teaching it. No lecturer-facing alert data exists yet,
/// so this stays an honest placeholder rather than reusing the
/// student tab against an endpoint it can't call.
class LecturerAlertsTab extends StatelessWidget {
  const LecturerAlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.notifications_none,
      title: 'Alerts',
      explanation:
          'Class reminders and attendance-rate alerts for the units you '
          'teach will show up here once that\'s built.',
    );
  }
}
