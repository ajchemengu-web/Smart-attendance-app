import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

class PigeonholeTab extends StatelessWidget {
  const PigeonholeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.mail_outline,
      title: 'Pigeonhole',
      explanation:
          'Official mail from admins and lecturers, plus announcements, '
          'will show up here once that backend feature is built.',
    );
  }
}
