import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

/// docs/PRD.md §7.3: History means something different per role —
/// a lecturer gets the attendance PDF per class they taught, not a
/// personal attendance record (that's the student History tab).
/// Depends on the classroom-camera attendance pipeline (§13 Phase 2,
/// "not started"), so shown as an honest placeholder.
class LecturerHistoryTab extends StatelessWidget {
  const LecturerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.picture_as_pdf_outlined,
      title: 'History',
      explanation:
          'The attendance PDF for each class you taught will show up here '
          'once the classroom-camera attendance pipeline is built.',
    );
  }
}
