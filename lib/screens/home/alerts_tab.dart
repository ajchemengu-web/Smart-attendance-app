import 'package:flutter/material.dart';

import '../../models/attendance_notification.dart';
import '../../services/api_client.dart';
import '../../services/session_expiry.dart';
import '../../services/session_store.dart';

/// docs/PRD.md §7.3's "Alerts" bottom-nav tab — the "You attended"/
/// "You missed a class" queue Alternative_Identifier's
/// attendance_service.py writes to attendance_notifications when a
/// class session is submitted. A plain polled list, not a push
/// notification — no push/SMS/email infra exists here either, same
/// as the web platform's own watchlist alerts.
class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  List<AttendanceNotification> _notifications = [];
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
      final notifications = await _apiClient.getMyNotifications(token);

      if (!mounted) return;

      setState(() => _notifications = notifications);
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

  Future<void> _markRead(AttendanceNotification notification) async {
    if (notification.isRead) return;

    final token = await _sessionStore.token;
    if (token == null) return;

    try {
      await _apiClient.markNotificationRead(notification.id, token);

      if (!mounted) return;

      setState(() {
        _notifications = [
          for (final existing in _notifications)
            if (existing.id == notification.id)
              existing.copyWithRead(DateTime.now().toIso8601String())
            else
              existing,
        ];
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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

    if (_notifications.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No attendance alerts yet — these show up once a class '
              'you\'re on the roster for finishes.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final attended = notification.kind == 'ATTENDED';

        return ListTile(
          onTap: () => _markRead(notification),
          leading: Icon(
            attended ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: attended ? Colors.green : Colors.orange,
          ),
          title: Text(
            attended ? 'You attended' : 'You missed a class',
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${notification.unitName}'
            '${notification.facilitator != null ? ' · ${notification.facilitator}' : ''}'
            '\n${notification.createdAt}',
          ),
          isThreeLine: true,
          trailing: notification.isRead
              ? null
              : const Icon(Icons.circle, size: 10, color: Colors.blue),
        );
      },
    );
  }
}
