import 'package:flutter_test/flutter_test.dart';

import 'package:smart_attendance/models/attendance_notification.dart';
import 'package:smart_attendance/models/attendance_record.dart';
import 'package:smart_attendance/models/consent.dart';
import 'package:smart_attendance/models/face_enroll_result.dart';
import 'package:smart_attendance/models/lecturer_profile.dart';
import 'package:smart_attendance/models/login_result.dart';
import 'package:smart_attendance/models/student_profile.dart';
import 'package:smart_attendance/models/taught_session.dart';
import 'package:smart_attendance/models/timetable_entry.dart';
import 'package:smart_attendance/models/unit.dart';

void main() {
  group('LoginResult.fromJson', () {
    test('parses a student login response', () {
      final result = LoginResult.fromJson({
        'username': 'alice.student',
        'email': 'alice@example.com',
        'role': 'STUDENT',
        'admin_tier': null,
        'dashboard': 'smartattendance_app',
        'access_token': 'tok123',
      });

      expect(result.username, 'alice.student');
      expect(result.role, 'STUDENT');
      expect(result.adminTier, isNull);
      expect(result.accessToken, 'tok123');
    });

    test('parses an admin login response with a tier', () {
      final result = LoginResult.fromJson({
        'username': 'original1',
        'email': 'original1@example.com',
        'role': 'ADMIN',
        'admin_tier': 'ORIGINAL',
        'dashboard': 'original_admin_dashboard',
        'access_token': 'tok456',
      });

      expect(result.role, 'ADMIN');
      expect(result.adminTier, 'ORIGINAL');
    });
  });

  group('StudentProfile.fromJson', () {
    test('parses a fully classified student', () {
      final profile = StudentProfile.fromJson({
        'student_id': 'S1',
        'full_name': 'Alice Wanjiru',
        'admission_number': 'AD001',
        'department': 'School of Computing',
        'course': 'BSc Computer Science',
        'year': 2,
        'semester': 1,
        'face_enrolled': true,
      });

      expect(profile.studentId, 'S1');
      expect(profile.course, 'BSc Computer Science');
      expect(profile.year, 2);
      expect(profile.semester, 1);
      expect(profile.faceEnrolled, isTrue);
    });

    test(
      'handles an unclassified student (null department/course/year/semester)',
      () {
        final profile = StudentProfile.fromJson({
          'student_id': 'S2',
          'full_name': 'Bob Otieno',
          'admission_number': 'AD002',
          'department': null,
          'course': null,
          'year': null,
          'semester': null,
          'face_enrolled': false,
        });

        expect(profile.department, isNull);
        expect(profile.course, isNull);
        expect(profile.year, isNull);
        expect(profile.semester, isNull);
        expect(profile.faceEnrolled, isFalse);
      },
    );

    test('defaults faceEnrolled to false when the key is missing', () {
      final profile = StudentProfile.fromJson({
        'student_id': 'S3',
        'full_name': 'Carol Njeri',
        'admission_number': 'AD003',
        'department': null,
        'course': null,
        'year': null,
        'semester': null,
      });

      expect(profile.faceEnrolled, isFalse);
    });
  });

  group('FaceEnrollResult.fromJson', () {
    test('parses a successful enrollment result', () {
      final result = FaceEnrollResult.fromJson({
        'student_id': 'S1',
        'full_name': 'Alice Wanjiru',
        'samples_used': 2,
        'samples_skipped': 1,
        'average_liveness_score': 0.82,
      });

      expect(result.studentId, 'S1');
      expect(result.samplesUsed, 2);
      expect(result.samplesSkipped, 1);
      expect(result.averageLivenessScore, closeTo(0.82, 0.0001));
    });

    test('handles a null average_liveness_score', () {
      final result = FaceEnrollResult.fromJson({
        'student_id': 'S1',
        'full_name': 'Alice Wanjiru',
        'samples_used': 1,
        'samples_skipped': 0,
        'average_liveness_score': null,
      });

      expect(result.averageLivenessScore, isNull);
    });
  });

  group('LecturerProfile.fromJson', () {
    test('parses a lecturer profile', () {
      final profile = LecturerProfile.fromJson({
        'lecturer_id': 'L1',
        'full_name': 'Dr. Otieno',
        'department': 'School of Computing',
      });

      expect(profile.lecturerId, 'L1');
      expect(profile.fullName, 'Dr. Otieno');
      expect(profile.department, 'School of Computing');
    });

    test('handles a lecturer with no department set', () {
      final profile = LecturerProfile.fromJson({
        'lecturer_id': 'L2',
        'full_name': 'Dr. Mwangi',
        'department': null,
      });

      expect(profile.department, isNull);
    });
  });

  group('TimetableEntry.fromJson', () {
    test('parses a full timetable entry referencing a claimed unit', () {
      final entry = TimetableEntry.fromJson({
        'id': 1,
        'unit_id': 10,
        'unit_code': 'SCO 104',
        'course': 'BSc Computer Science',
        'year': 2,
        'department': 'School of Computing',
        'semester': 1,
        'lecturer_id': 'L1',
        'day_of_week': 'MONDAY',
        'start_time': '09:00',
        'end_time': '11:00',
        'unit_name': 'Data Structures',
        'facilitator': 'Dr. Otieno',
        'venue': 'Hall A',
        'status': 'ON',
      });

      expect(entry.id, 1);
      expect(entry.unitId, 10);
      expect(entry.unitCode, 'SCO 104');
      expect(entry.lecturerId, 'L1');
      expect(entry.unitName, 'Data Structures');
      expect(entry.status, 'ON');
      expect(entry.semester, 1);
    });

    test(
      'handles an entry for a still-unclaimed unit (null lecturer_id/facilitator)',
      () {
        final entry = TimetableEntry.fromJson({
          'id': 2,
          'unit_id': 11,
          'unit_code': 'BCM 101',
          'course': 'BCom',
          'year': 1,
          'department': null,
          'semester': null,
          'lecturer_id': null,
          'day_of_week': 'TUESDAY',
          'start_time': '08:00',
          'end_time': '10:00',
          'unit_name': 'Accounting',
          'facilitator': null,
          'venue': 'Hall D',
          'status': 'POSTPONED',
        });

        expect(entry.department, isNull);
        expect(entry.semester, isNull);
        expect(entry.lecturerId, isNull);
        expect(entry.facilitator, isNull);
        expect(entry.status, 'POSTPONED');
      },
    );
  });

  group('Unit.fromJson', () {
    test('parses a claimed unit', () {
      final unit = Unit.fromJson({
        'id': 10,
        'unit_code': 'SCO 104',
        'unit_name': 'Data Structures',
        'department': 'School of Computing',
        'course': 'BSc Computer Science',
        'year': 2,
        'semester': 1,
        'lecturer_id': 'L1',
      });

      expect(unit.unitCode, 'SCO 104');
      expect(unit.lecturerId, 'L1');
    });

    test('parses an unclaimed unit', () {
      final unit = Unit.fromJson({
        'id': 11,
        'unit_code': 'BCM 101',
        'unit_name': 'Accounting',
        'department': null,
        'course': 'BCom',
        'year': 1,
        'semester': 1,
        'lecturer_id': null,
      });

      expect(unit.lecturerId, isNull);
    });
  });

  group('AttendanceNotification.fromJson', () {
    test('parses an unread ATTENDED notification', () {
      final notification = AttendanceNotification.fromJson({
        'id': 1,
        'kind': 'ATTENDED',
        'unit_name': 'Data Structures',
        'facilitator': 'Dr. Otieno',
        'created_at': '2026-09-30 10:40:00',
        'read_at': null,
      });

      expect(notification.kind, 'ATTENDED');
      expect(notification.isRead, isFalse);
    });

    test('copyWithRead marks it read without touching other fields', () {
      final notification = AttendanceNotification.fromJson({
        'id': 2,
        'kind': 'MISSED',
        'unit_name': 'Accounting',
        'facilitator': null,
        'created_at': '2026-09-30 10:40:00',
        'read_at': null,
      });

      final read = notification.copyWithRead('2026-09-30T11:00:00');

      expect(read.isRead, isTrue);
      expect(read.kind, 'MISSED');
      expect(read.id, 2);
    });
  });

  group('AttendanceRecord.fromJson', () {
    test('parses a PRESENT record', () {
      final record = AttendanceRecord.fromJson({
        'status': 'PRESENT',
        'recognized_at': '2026-09-30 09:52:00',
        'session_date': '2026-09-30',
        'unit_name': 'Data Structures',
        'facilitator': 'Dr. Otieno',
        'start_time': '10:00',
        'end_time': '11:00',
      });

      expect(record.status, 'PRESENT');
      expect(record.recognizedAt, isNotNull);
    });

    test('parses an ABSENT record with no recognized_at', () {
      final record = AttendanceRecord.fromJson({
        'status': 'ABSENT',
        'recognized_at': null,
        'session_date': '2026-09-30',
        'unit_name': 'Data Structures',
        'facilitator': null,
        'start_time': '10:00',
        'end_time': '11:00',
      });

      expect(record.status, 'ABSENT');
      expect(record.recognizedAt, isNull);
      expect(record.facilitator, isNull);
    });
  });

  group('TaughtSession.fromJson', () {
    test('parses a submitted session with its full roll', () {
      final session = TaughtSession.fromJson({
        'class_session_id': 1,
        'session_date': '2026-09-30',
        'status': 'SUBMITTED',
        'unit_name': 'Data Structures',
        'start_time': '10:00',
        'end_time': '11:00',
        'venue': 'Room 204',
        'roll': [
          {
            'student_id': 'STU-1',
            'full_name': 'Alice Example',
            'status': 'PRESENT',
            'recognized_at': '2026-09-30 09:52:00',
          },
          {
            'student_id': 'STU-2',
            'full_name': 'Bob Example',
            'status': 'ABSENT',
            'recognized_at': null,
          },
        ],
      });

      expect(session.roll, hasLength(2));
      expect(session.roll[0].status, 'PRESENT');
      expect(session.roll[1].recognizedAt, isNull);
    });
  });

  group('ConsentInfo.fromJson', () {
    test('parses the notice and an inactive status', () {
      final info = ConsentInfo.fromJson({
        'notice': {
          'version': '2026-09-v1',
          'title': 'Facial recognition consent',
          'controller': 'Example University',
          'contact': 'dpo@example.ac.ke',
          'sections': [
            {'heading': 'What we collect', 'body': 'A face template.'},
            {'heading': 'Your choice', 'body': 'You do not have to agree.'},
          ],
        },
        'status': {
          'consent_active': false,
          'notice_version': null,
          'granted_at': null,
          'channel': null,
          'needs_reconsent': false,
          'current_notice_version': '2026-09-v1',
        },
      });

      expect(info.notice.version, '2026-09-v1');
      expect(info.notice.sections, hasLength(2));
      expect(info.notice.sections[1].heading, 'Your choice');
      expect(info.status.consentActive, isFalse);
      expect(info.status.needsReconsent, isFalse);
      expect(info.status.grantedAt, isNull);
    });

    test('flags a consent that needs re-asking after the notice changed', () {
      final status = ConsentStatus.fromJson({
        'consent_active': false,
        'granted_at': null,
        'needs_reconsent': true,
        'current_notice_version': '2026-12-v2',
      });

      expect(status.needsReconsent, isTrue);
      expect(status.currentNoticeVersion, '2026-12-v2');
    });

    test('defaults needsReconsent to false when the key is missing', () {
      final status = ConsentStatus.fromJson({
        'consent_active': true,
        'granted_at': '2026-09-29 10:00:00',
        'current_notice_version': '2026-09-v1',
      });

      expect(status.consentActive, isTrue);
      expect(status.needsReconsent, isFalse);
    });
  });

  group('ConsentWithdrawResult.fromJson', () {
    test('reports that the face data was deleted', () {
      final result = ConsentWithdrawResult.fromJson({
        'student_id': 'STU-1',
        'consent_withdrawn': true,
        'face_data_deleted': true,
      });

      expect(result.consentWithdrawn, isTrue);
      expect(result.faceDataDeleted, isTrue);
    });
  });
}
