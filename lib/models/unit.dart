/// A unit in the registry a lecturer self-registers from
/// (Alternative_Identifier's unit_service.py): created once by the
/// Timetabling Admin, then claimed by whichever lecturer teaches it
/// — that claim (lecturerId) is what a timetable entry's own
/// lecturer/facilitator gets derived from, not a name typed onto
/// the entry.
class Unit {
  final int id;
  final String unitCode;
  final String unitName;
  final String? department;
  final String course;
  final int year;
  final int semester;
  final String? lecturerId;

  Unit({
    required this.id,
    required this.unitCode,
    required this.unitName,
    required this.department,
    required this.course,
    required this.year,
    required this.semester,
    required this.lecturerId,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      unitCode: json['unit_code'] as String,
      unitName: json['unit_name'] as String,
      department: json['department'] as String?,
      course: json['course'] as String,
      year: json['year'] as int,
      semester: json['semester'] as int,
      lecturerId: json['lecturer_id'] as String?,
    );
  }
}
