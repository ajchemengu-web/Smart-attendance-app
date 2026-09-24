import 'package:flutter/material.dart';

import '../../models/timetable_entry.dart';
import '../../widgets/status_badge.dart';

const _weekdayNames = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

/// Only the classes a lecturer is teaching *today*, with live status
/// (docs/PRD.md §7.3's "Intraday" top-nav tab) — filtered client-side
/// from the same timetable entries the Schedule tab shows.
class LecturerIntradayTab extends StatelessWidget {
  final List<TimetableEntry> entries;

  const LecturerIntradayTab({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final today = _weekdayNames[DateTime.now().weekday - 1];
    final todaysEntries = entries
        .where((entry) => entry.dayOfWeek.toUpperCase() == today)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (todaysEntries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No classes scheduled for today.'),
        ),
      );
    }

    return ListView.builder(
      itemCount: todaysEntries.length,
      itemBuilder: (context, index) {
        final entry = todaysEntries[index];
        return ListTile(
          title: Text(entry.unitName),
          subtitle: Text(
            '${entry.course} · Year ${entry.year} · '
            '${entry.startTime}–${entry.endTime} · ${entry.venue}',
          ),
          trailing: StatusBadge(status: entry.status),
        );
      },
    );
  }
}
