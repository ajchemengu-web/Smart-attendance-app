/// One titled paragraph of the consent notice.
class NoticeSection {
  final String heading;
  final String body;

  NoticeSection({required this.heading, required this.body});

  factory NoticeSection.fromJson(Map<String, dynamic> json) {
    return NoticeSection(
      heading: json['heading'] as String,
      body: json['body'] as String,
    );
  }
}

/// The exact text a student agrees to before their face is enrolled
/// (Alternative_Identifier's consent_service.get_notice) — served by
/// the backend rather than hardcoded here, so what's shown always
/// matches the [version] that gets recorded.
class ConsentNotice {
  final String version;
  final String title;
  final String controller;
  final String contact;
  final List<NoticeSection> sections;

  ConsentNotice({
    required this.version,
    required this.title,
    required this.controller,
    required this.contact,
    required this.sections,
  });

  factory ConsentNotice.fromJson(Map<String, dynamic> json) {
    return ConsentNotice(
      version: json['version'] as String,
      title: json['title'] as String,
      controller: json['controller'] as String,
      contact: json['contact'] as String,
      sections: (json['sections'] as List)
          .map((e) => NoticeSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ConsentStatus {
  final bool consentActive;

  /// Consent was given against an older notice than the current one, so
  /// it no longer counts and the student should be asked again.
  final bool needsReconsent;
  final String? grantedAt;
  final String currentNoticeVersion;

  ConsentStatus({
    required this.consentActive,
    required this.needsReconsent,
    required this.grantedAt,
    required this.currentNoticeVersion,
  });

  factory ConsentStatus.fromJson(Map<String, dynamic> json) {
    return ConsentStatus(
      consentActive: json['consent_active'] as bool,
      needsReconsent: json['needs_reconsent'] as bool? ?? false,
      grantedAt: json['granted_at'] as String?,
      currentNoticeVersion: json['current_notice_version'] as String,
    );
  }
}

/// GET /me/consent: the notice plus this student's status against it.
class ConsentInfo {
  final ConsentNotice notice;
  final ConsentStatus status;

  ConsentInfo({required this.notice, required this.status});

  factory ConsentInfo.fromJson(Map<String, dynamic> json) {
    return ConsentInfo(
      notice: ConsentNotice.fromJson(json['notice'] as Map<String, dynamic>),
      status: ConsentStatus.fromJson(json['status'] as Map<String, dynamic>),
    );
  }
}

/// POST /me/consent/withdraw: withdrawal deletes the stored face
/// template as well as recording the withdrawal.
class ConsentWithdrawResult {
  final bool consentWithdrawn;
  final bool faceDataDeleted;

  ConsentWithdrawResult({
    required this.consentWithdrawn,
    required this.faceDataDeleted,
  });

  factory ConsentWithdrawResult.fromJson(Map<String, dynamic> json) {
    return ConsentWithdrawResult(
      consentWithdrawn: json['consent_withdrawn'] as bool,
      faceDataDeleted: json['face_data_deleted'] as bool,
    );
  }
}
