import 'package:flutter/material.dart';

import '../../models/taught_session.dart';
import '../../services/api_client.dart';
import '../../services/session_expiry.dart';
import '../../services/session_store.dart';

/// docs/PRD.md §7.2's "class attendance PDF" in the lecturer History
/// tab (Alternative_Identifier's GET /lecturers/me/attendance) — the
/// plain-list version of that data; actual PDF formatting/export is
/// still future work.
class LecturerHistoryTab extends StatefulWidget {
  const LecturerHistoryTab({super.key});

  @override
  State<LecturerHistoryTab> createState() => _LecturerHistoryTabState();
}

class _LecturerHistoryTabState extends State<LecturerHistoryTab> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  List<TaughtSession> _sessions = [];
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
    if (token == null) return;

    try {
      final sessions = await _apiClient.getMyTaughtAttendance(token);

      if (!mounted) return;

      setState(() => _sessions = sessions);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(onRefresh: _load, child: _buildList());
  }

  Widget _buildList() {
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

    if (_sessions.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No submitted attendance rolls yet — these show up once a '
              'class you teach finishes.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final presentCount = session.roll
            .where((entry) => entry.status == 'PRESENT')
            .length;

        return ExpansionTile(
          title: Text(session.unitName),
          subtitle: Text(
            '${session.sessionDate} · ${session.startTime}–${session.endTime} '
            '· ${session.venue} · $presentCount/${session.roll.length} present',
          ),
          children: [
            for (final entry in session.roll)
              ListTile(
                title: Text(entry.fullName),
                trailing: Text(
                  entry.status,
                  style: TextStyle(
                    color: entry.status == 'PRESENT'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
