/// One row of a submitted roll (Alternative_Identifier's GET
/// /lecturers/me/attendance) — a single student's outcome within a
/// class session the lecturer taught.
class RollEntry {
  final String studentId;
  final String fullName;
  final String status; // 'PRESENT' | 'ABSENT'
  final String? recognizedAt;

  RollEntry({
    required this.studentId,
    required this.fullName,
    required this.status,
    required this.recognizedAt,
  });

  factory RollEntry.fromJson(Map<String, dynamic> json) {
    return RollEntry(
      studentId: json['student_id'] as String,
      fullName: json['full_name'] as String,
      status: json['status'] as String,
      recognizedAt: json['recognized_at'] as String?,
    );
  }
}

/// A submitted class session a lecturer taught, with its full roll —
/// the plain-list data source for docs/PRD.md §7.2's "class
/// attendance PDF" (PDF formatting itself is still future work).
class TaughtSession {
  final int classSessionId;
  final String sessionDate;
  final String status;
  final String unitName;
  final String startTime;
  final String endTime;
  final String venue;
  final List<RollEntry> roll;

  TaughtSession({
    required this.classSessionId,
    required this.sessionDate,
    required this.status,
    required this.unitName,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.roll,
  });

  factory TaughtSession.fromJson(Map<String, dynamic> json) {
    return TaughtSession(
      classSessionId: json['class_session_id'] as int,
      sessionDate: json['session_date'] as String,
      status: json['status'] as String,
      unitName: json['unit_name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      venue: json['venue'] as String,
      roll: (json['roll'] as List)
          .map((e) => RollEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
