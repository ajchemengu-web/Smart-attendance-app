/// The "You attended"/"You missed a class" queue
/// (Alternative_Identifier's attendance_service.py writes one of
/// these per expected student when a class session is submitted) —
/// a plain polled list, not a push notification, since no push/SMS/
/// email infra exists (same pattern as the web platform's own
/// watchlist alerts).
class AttendanceNotification {
  final int id;
  final String kind; // 'ATTENDED' | 'MISSED'
  final String unitName;
  final String? facilitator;
  final String createdAt;
  final String? readAt;

  AttendanceNotification({
    required this.id,
    required this.kind,
    required this.unitName,
    required this.facilitator,
    required this.createdAt,
    required this.readAt,
  });

  bool get isRead => readAt != null;

  AttendanceNotification copyWithRead(String readAt) {
    return AttendanceNotification(
      id: id,
      kind: kind,
      unitName: unitName,
      facilitator: facilitator,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  factory AttendanceNotification.fromJson(Map<String, dynamic> json) {
    return AttendanceNotification(
      id: json['id'] as int,
      kind: json['kind'] as String,
      unitName: json['unit_name'] as String,
      facilitator: json['facilitator'] as String?,
      createdAt: json['created_at'] as String,
      readAt: json['read_at'] as String?,
    );
  }
}
