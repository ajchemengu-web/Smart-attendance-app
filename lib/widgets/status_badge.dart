import 'package:flutter/material.dart';

/// A timetable entry's ON/POSTPONED/CANCELLED status — shared between
/// the Schedule and Intraday tabs, which both list timetable entries.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'ON':
        color = Colors.green;
        break;
      case 'POSTPONED':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Text(status, style: TextStyle(color: color, fontSize: 12));
  }
}
