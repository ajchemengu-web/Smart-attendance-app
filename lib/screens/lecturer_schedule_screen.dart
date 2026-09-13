import 'package:flutter/material.dart';

import '../models/lecturer_profile.dart';
import '../models/timetable_entry.dart';
import '../services/api_client.dart';
import '../services/session_store.dart';
import 'login_screen.dart';

/// A lecturer's "My Units" (docs/PRD.md §6): resolves their own
/// profile via GET /me, then matches their full_name against
/// timetable_entries.facilitator via GET /timetable?facilitator= —
/// a free-text match, not a foreign key (see this repo's README and
/// Alternative_Identifier's timetable_service.py), so an entry only
/// shows up here if the Timetabling Admin typed this lecturer's name
/// into it exactly as it's registered.
class LecturerScheduleScreen extends StatefulWidget {
  const LecturerScheduleScreen({super.key});

  @override
  State<LecturerScheduleScreen> createState() =>
      _LecturerScheduleScreenState();
}

class _LecturerScheduleScreenState extends State<LecturerScheduleScreen> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  LecturerProfile? _profile;
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
      final profile = await _apiClient.getMyLecturerProfile(token);
      final entries = await _apiClient.getTimetable(
        token,
        facilitator: profile.fullName,
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _entries = entries;
      });
    } on ApiException catch (error) {
      if (error.status == 401) {
        _goToLogin();
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
    await _sessionStore.clear();
    _goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Units'),
        actions: [
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
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

    if (_entries.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No timetable entries found for ${_profile?.fullName ?? 'you'} '
              'yet — make sure the Timetabling Admin entered your name '
              'exactly as registered.',
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
            '${entry.course} · Year ${entry.year} · ${entry.dayOfWeek} '
            '${entry.startTime}–${entry.endTime} · ${entry.venue}',
          ),
          trailing: Text(
            entry.status,
            style: TextStyle(
              color: entry.status == 'ON'
                  ? Colors.green
                  : entry.status == 'POSTPONED'
                  ? Colors.orange
                  : Colors.red,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
