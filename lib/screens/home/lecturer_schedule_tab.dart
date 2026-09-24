import 'package:flutter/material.dart';

import '../../models/lecturer_profile.dart';
import '../../models/timetable_entry.dart';
import '../../widgets/status_badge.dart';

/// A lecturer's general timetable across all the units they've
/// claimed (docs/PRD.md §7.3's "Schedule" top-nav tab, §6) — same
/// data LecturerHomeShell already fetched via
/// GET /timetable?lecturer_id=.
class LecturerScheduleTab extends StatelessWidget {
  final LecturerProfile? profile;
  final List<TimetableEntry> entries;

  const LecturerScheduleTab({
    super.key,
    required this.profile,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No timetable entries found for ${profile?.fullName ?? 'you'} '
              'yet — use the Profile tab to register the units you teach, '
              'or ask the Timetabling Admin to assign them to you.',
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
            '${entry.course} · Year ${entry.year} · '
            'Sem ${entry.semester ?? '—'} · ${entry.dayOfWeek} '
            '${entry.startTime}–${entry.endTime} · ${entry.venue}',
          ),
          trailing: StatusBadge(status: entry.status),
        );
      },
    );
  }
}
