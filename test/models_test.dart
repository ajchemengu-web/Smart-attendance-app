import 'package:flutter_test/flutter_test.dart';

import 'package:smart_attendance/models/lecturer_profile.dart';
import 'package:smart_attendance/models/login_result.dart';
import 'package:smart_attendance/models/student_profile.dart';
import 'package:smart_attendance/models/timetable_entry.dart';

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
      });

      expect(profile.studentId, 'S1');
      expect(profile.course, 'BSc Computer Science');
      expect(profile.year, 2);
      expect(profile.semester, 1);
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
        });

        expect(profile.department, isNull);
        expect(profile.course, isNull);
        expect(profile.year, isNull);
        expect(profile.semester, isNull);
      },
    );
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
    test('parses a full timetable entry', () {
      final entry = TimetableEntry.fromJson({
        'id': 1,
        'course': 'BSc Computer Science',
        'year': 2,
        'department': 'School of Computing',
        'semester': 1,
        'day_of_week': 'MONDAY',
        'start_time': '09:00',
        'end_time': '11:00',
        'unit_name': 'Data Structures',
        'facilitator': 'Dr. Otieno',
        'venue': 'Hall A',
        'status': 'ON',
      });

      expect(entry.id, 1);
      expect(entry.unitName, 'Data Structures');
      expect(entry.status, 'ON');
      expect(entry.semester, 1);
    });

    test('handles a null department/semester (course-only timetable entry)', () {
      final entry = TimetableEntry.fromJson({
        'id': 2,
        'course': 'BCom',
        'year': 1,
        'department': null,
        'semester': null,
        'day_of_week': 'TUESDAY',
        'start_time': '08:00',
        'end_time': '10:00',
        'unit_name': 'Accounting',
        'facilitator': 'Dr. Mwangi',
        'venue': 'Hall D',
        'status': 'POSTPONED',
      });

      expect(entry.department, isNull);
      expect(entry.semester, isNull);
      expect(entry.status, 'POSTPONED');
    });
  });
}
