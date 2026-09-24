class FaceEnrollResult {
  final String studentId;
  final String fullName;
  final int samplesUsed;
  final int samplesSkipped;
  final double? averageLivenessScore;

  FaceEnrollResult({
    required this.studentId,
    required this.fullName,
    required this.samplesUsed,
    required this.samplesSkipped,
    required this.averageLivenessScore,
  });

  factory FaceEnrollResult.fromJson(Map<String, dynamic> json) {
    return FaceEnrollResult(
      studentId: json['student_id'] as String,
      fullName: json['full_name'] as String,
      samplesUsed: json['samples_used'] as int,
      samplesSkipped: json['samples_skipped'] as int,
      averageLivenessScore: (json['average_liveness_score'] as num?)
          ?.toDouble(),
    );
  }
}
