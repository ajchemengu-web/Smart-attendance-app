import 'package:flutter/material.dart';

import '../models/student_profile.dart';
import '../models/timetable_entry.dart';
import '../services/api_client.dart';
import '../services/session_expiry.dart';
import '../services/session_store.dart';
import 'face_enrollment_screen.dart';
import 'login_screen.dart';

/// A student's "My Schedule" (docs/PRD.md §6): their own
/// department/course/year/semester resolved via GET /me, then their
/// timetable via GET /timetable — the same read-only timetable data
/// the web platform's Timetabling Admin dashboard manages, filtered
/// down to just this student's own semester (semester 1 and semester
/// 2 commonly run different schedules for the same course & year).
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  StudentProfile? _profile;
  List<TimetableEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await _sessionStore.token;

    if (token == null) {
      _goToLogin();
      return;
    }

    try {
      final profile = await _apiClient.getMe(token);
      final entries = await _apiClient.getTimetable(
        token,
        department: profile.department,
        course: profile.course,
        year: profile.year,
        semester: profile.semester,
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _entries = entries;
      });
    } on ApiException catch (error) {
      if (error.status == 401) {
        if (!mounted) return;
        await handleUnauthorized(context);
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleSignOut() async {
    await handleUnauthorized(context);
  }

  Future<void> _goToFaceEnrollment() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FaceEnrollmentScreen()));
    // Refresh so a newly-enrolled face's status shows immediately.
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            onPressed: _goToFaceEnrollment,
            icon: Icon(
              _profile?.faceEnrolled == true
                  ? Icons.face_retouching_natural
                  : Icons.face,
            ),
            tooltip: _profile?.faceEnrolled == true
                ? 'Re-enroll your face'
                : 'Enroll your face',
          ),
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            if (!_loading && _profile != null && !_profile!.faceEnrolled)
              _FaceEnrollmentBanner(onTap: _goToFaceEnrollment),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    final profile = _profile;

    if (profile == null ||
        profile.course == null ||
        profile.year == null ||
        profile.semester == null) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your account isn\'t assigned to a course/year/semester '
              'yet — ask an admin to update your enrollment record.',
            ),
          ),
        ],
      );
    }

    if (_entries.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No timetable entries for ${profile.course} (Year '
              '${profile.year}, Semester ${profile.semester}) yet.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return ListTile(
          title: Text(entry.unitName),
          subtitle: Text(
            '${entry.dayOfWeek} ${entry.startTime}–${entry.endTime} · '
            '${entry.venue} · ${entry.facilitator ?? "Unassigned"}',
          ),
          trailing: _StatusBadge(status: entry.status),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'ON':
        color = Colors.green;
        break;
      case 'POSTPONED':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Text(status, style: TextStyle(color: color, fontSize: 12));
  }
}

class _FaceEnrollmentBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _FaceEnrollmentBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.face),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your face isn\'t enrolled yet — tap to set it up. '
                  'This is what lets you be recognized at checkpoints.',
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
