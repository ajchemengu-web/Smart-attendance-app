/// One row of a student's own attendance history
/// (Alternative_Identifier's GET /me/attendance) — an
/// attendance_records row joined to its class_sessions/
/// timetable_entries, one per class session the student was ever
/// expected in (present or absent), not just the ones they attended.
class AttendanceRecord {
  final String status; // 'PRESENT' | 'ABSENT'
  final String? recognizedAt;
  final String sessionDate;
  final String unitName;
  final String? facilitator;
  final String startTime;
  final String endTime;

  AttendanceRecord({
    required this.status,
    required this.recognizedAt,
    required this.sessionDate,
    required this.unitName,
    required this.facilitator,
    required this.startTime,
    required this.endTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      status: json['status'] as String,
      recognizedAt: json['recognized_at'] as String?,
      sessionDate: json['session_date'] as String,
      unitName: json['unit_name'] as String,
      facilitator: json['facilitator'] as String?,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}
