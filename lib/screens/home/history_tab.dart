import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/api_client.dart';
import '../../services/session_expiry.dart';
import '../../services/session_store.dart';

/// docs/PRD.md §7.3's student "History" tab — the student's own
/// personal attendance history (Alternative_Identifier's GET
/// /me/attendance), one row per class session they were ever
/// expected in, present or absent.
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  List<AttendanceRecord> _records = [];
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
      final records = await _apiClient.getMyAttendance(token);

      if (!mounted) return;

      setState(() => _records = records);
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

    if (_records.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No attendance history yet — this fills in once a class '
              'you\'re on the roster for finishes.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final present = record.status == 'PRESENT';

        return ListTile(
          title: Text(record.unitName),
          subtitle: Text(
            '${record.sessionDate} · ${record.startTime}–${record.endTime}'
            '${record.facilitator != null ? ' · ${record.facilitator}' : ''}',
          ),
          trailing: Text(
            record.status,
            style: TextStyle(
              color: present ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
