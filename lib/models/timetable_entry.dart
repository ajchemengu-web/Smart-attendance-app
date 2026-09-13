class TimetableEntry {
  final int id;
  final String course;
  final int year;
  final String? department;
  final int? semester;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String unitName;
  final String facilitator;
  final String venue;
  final String status;

  TimetableEntry({
    required this.id,
    required this.course,
    required this.year,
    required this.department,
    required this.semester,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.unitName,
    required this.facilitator,
    required this.venue,
    required this.status,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] as int,
      course: json['course'] as String,
      year: json['year'] as int,
      department: json['department'] as String?,
      semester: json['semester'] as int?,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      unitName: json['unit_name'] as String,
      facilitator: json['facilitator'] as String,
      venue: json['venue'] as String,
      status: json['status'] as String,
    );
  }
}
