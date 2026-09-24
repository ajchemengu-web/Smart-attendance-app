import 'package:flutter/material.dart';

import '../../models/student_profile.dart';
import '../../models/timetable_entry.dart';
import '../../widgets/status_badge.dart';

/// A student's general timetable for their course & year (docs/PRD.md
/// §7.3's "Schedule" top-nav tab) — read-only, same data HomeShell
/// already fetched (no separate request per tab).
class ScheduleTab extends StatelessWidget {
  final StudentProfile? profile;
  final List<TimetableEntry> entries;

  const ScheduleTab({super.key, required this.profile, required this.entries});

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;

    if (profile == null ||
        profile.course == null ||
        profile.year == null ||
        profile.semester == null) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your account isn\'t assigned to a course/year/semester '
              'yet — ask an admin to update your enrollment record.',
            ),
          ),
        ],
      );
    }

    if (entries.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No timetable entries for ${profile.course} (Year '
              '${profile.year}, Semester ${profile.semester}) yet.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          title: Text(entry.unitName),
          subtitle: Text(
            '${entry.dayOfWeek} ${entry.startTime}–${entry.endTime} · '
            '${entry.venue} · ${entry.facilitator ?? "Unassigned"}',
          ),
          trailing: StatusBadge(status: entry.status),
        );
      },
    );
  }
}
