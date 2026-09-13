import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/lecturer_profile.dart';
import '../models/login_result.dart';
import '../models/student_profile.dart';
import '../models/timetable_entry.dart';

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

  Future<List<TimetableEntry>> getTimetable(
    String token, {
    String? department,
    String? course,
    int? year,
    int? semester,
    String? facilitator,
  }) {
    final params = <String, String>{};
    if (department != null) params['department'] = department;
    if (course != null) params['course'] = course;
    if (year != null) params['year'] = year.toString();
    if (semester != null) params['semester'] = semester.toString();
    if (facilitator != null) params['facilitator'] = facilitator;
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
}
