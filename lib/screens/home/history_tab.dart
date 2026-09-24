import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.history,
      title: 'History',
      explanation:
          'Your personal attendance history will show up here once the '
          'classroom-camera attendance pipeline is built.',
    );
  }
}
