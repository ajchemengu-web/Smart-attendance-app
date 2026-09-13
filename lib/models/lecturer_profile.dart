class LecturerProfile {
  final String lecturerId;
  final String fullName;
  final String? department;

  LecturerProfile({
    required this.lecturerId,
    required this.fullName,
    required this.department,
  });

  factory LecturerProfile.fromJson(Map<String, dynamic> json) {
    return LecturerProfile(
      lecturerId: json['lecturer_id'] as String,
      fullName: json['full_name'] as String,
      department: json['department'] as String?,
    );
  }
}
