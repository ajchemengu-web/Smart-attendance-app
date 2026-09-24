import 'package:flutter/material.dart';

/// Honest placeholder for a nav section with real UI but no backend
/// data behind it yet — rather than fabricating fake content. Used
/// by Pigeonhole, Alerts, and History (docs/PRD.md §7.3), which all
/// depend on backend features that don't exist yet: a mailing/
/// announcements system, and the classroom-camera attendance
/// pipeline (PRD §13 Phase 2, marked "not started" — no attendance
/// records are generated anywhere in the system yet).
class ComingSoon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String explanation;

  const ComingSoon({
    super.key,
    required this.icon,
    required this.title,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.black38),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
