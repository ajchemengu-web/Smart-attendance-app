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

/// Only *today's* classes, with live status (docs/PRD.md §7.3's
/// "Intraday" top-nav tab) — filtered client-side from the same
/// timetable entries the Schedule tab shows, by day_of_week matching
/// today. No separate backend endpoint: entries carry no date, only
/// a recurring day_of_week, so "today" is derived from the device
/// clock rather than requested from the server.
class IntradayTab extends StatelessWidget {
  final List<TimetableEntry> entries;

  const IntradayTab({super.key, required this.entries});

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
            '${entry.startTime}–${entry.endTime} · ${entry.venue} · '
            '${entry.facilitator ?? "Unassigned"}',
          ),
          trailing: StatusBadge(status: entry.status),
        );
      },
    );
  }
}
