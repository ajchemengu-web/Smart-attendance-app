import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/face_enroll_result.dart';
import '../models/lecturer_profile.dart';
import '../models/login_result.dart';
import '../models/student_profile.dart';
import '../models/timetable_entry.dart';
import '../models/unit.dart';

/// Talks to the same FastAPI backend the web platform uses
/// (Alternative_Identifier's src/api/main.py). Every endpoint except
/// POST /login requires an `Authorization: Bearer <access_token>`
/// header (src/api/deps.py in that repo).
class ApiException implements Exception {
  final int status;
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  Future<T> _get<T>(
    String path,
    String token,
    T Function(dynamic) parse,
  ) async {
    late http.Response response;

    try {
      response = await http.get(
        Uri.parse('$apiBaseUrl$path'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw ApiException(0, 'Could not reach the backend API.');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        data is Map && data['detail'] != null
            ? data['detail'].toString()
            : 'Request failed',
      );
    }

    return parse(data);
  }

  Future<T> _patch<T>(
    String path,
    String token,
    Map<String, dynamic> body,
    T Function(dynamic) parse,
  ) async {
    late http.Response response;

    try {
      response = await http.patch(
        Uri.parse('$apiBaseUrl$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw ApiException(0, 'Could not reach the backend API.');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        data is Map && data['detail'] != null
            ? data['detail'].toString()
            : 'Request failed',
      );
    }

    return parse(data);
  }

  Future<LoginResult> login(String username, String password) async {
    late http.Response response;

    try {
      response = await http.post(
        Uri.parse('$apiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
    } catch (_) {
      throw ApiException(0, 'Could not reach the backend API.');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        data is Map && data['detail'] != null
            ? data['detail'].toString()
            : 'Invalid credentials',
      );
    }

    return LoginResult.fromJson(data as Map<String, dynamic>);
  }

  Future<StudentProfile> getMe(String token) {
    return _get(
      '/me',
      token,
      (data) => StudentProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<LecturerProfile> getMyLecturerProfile(String token) {
    return _get(
      '/me',
      token,
      (data) => LecturerProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Self-service counterpart to the admin-run enrollment on the web
  /// platform — resolves the caller's own student record server-side
  /// (Alternative_Identifier's enrollment_service.enroll_own_face)
  /// and requires every photo to pass the liveness check there;
  /// there's no admin present here to catch a spoofed photo.
  Future<FaceEnrollResult> enrollMyFace(
    List<Uint8List> photos,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiBaseUrl/me/enroll-face'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    for (var i = 0; i < photos.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          photos[i],
          filename: 'capture_$i.jpg',
        ),
      );
    }

    late http.StreamedResponse streamed;

    try {
      streamed = await request.send();
    } catch (_) {
      throw ApiException(0, 'Could not reach the backend API.');
    }

    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        data is Map && data['detail'] != null
            ? data['detail'].toString()
            : 'Could not enroll your face.',
      );
    }

    return FaceEnrollResult.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TimetableEntry>> getTimetable(
    String token, {
    String? department,
    String? course,
    int? year,
    int? semester,
    String? facilitator,
    String? lecturerId,
  }) {
    final params = <String, String>{};
    if (department != null) params['department'] = department;
    if (course != null) params['course'] = course;
    if (year != null) params['year'] = year.toString();
    if (semester != null) params['semester'] = semester.toString();
    if (facilitator != null) params['facilitator'] = facilitator;
    if (lecturerId != null) params['lecturer_id'] = lecturerId;
    final query = params.isEmpty
        ? ''
        : '?${Uri(queryParameters: params).query}';

    return _get(
      '/timetable$query',
      token,
      (data) => (data as List)
          .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<Unit>> getUnits(
    String token, {
    String? department,
    bool? unclaimed,
  }) {
    final params = <String, String>{};
    if (department != null) params['department'] = department;
    if (unclaimed != null) params['unclaimed'] = unclaimed.toString();
    final query = params.isEmpty
        ? ''
        : '?${Uri(queryParameters: params).query}';

    return _get(
      '/units$query',
      token,
      (data) => (data as List)
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Unit> claimUnit(int unitId, String token) {
    return _patch(
      '/units/$unitId/claim',
      token,
      const {},
      (data) => Unit.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Unit> unclaimUnit(int unitId, String token) {
    return _patch(
      '/units/$unitId/unclaim',
      token,
      const {},
      (data) => Unit.fromJson(data as Map<String, dynamic>),
    );
  }
}
