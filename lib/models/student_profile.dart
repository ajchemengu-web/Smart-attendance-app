class StudentProfile {
  final String studentId;
  final String fullName;
  final String admissionNumber;
  final String? department;
  final String? course;
  final int? year;
  final int? semester;

  StudentProfile({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
    required this.department,
    required this.course,
    required this.year,
    required this.semester,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentId: json['student_id'] as String,
      fullName: json['full_name'] as String,
      admissionNumber: json['admission_number'] as String,
      department: json['department'] as String?,
      course: json['course'] as String?,
      year: json['year'] as int?,
      semester: json['semester'] as int?,
    );
  }
}
