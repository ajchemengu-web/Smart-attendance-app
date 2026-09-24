import 'package:flutter/material.dart';

import '../../models/lecturer_profile.dart';
import '../../models/timetable_entry.dart';
import '../../services/api_client.dart';
import '../../services/session_expiry.dart';
import '../../services/session_store.dart';
import '../login_screen.dart';
import '../unit_registration_screen.dart';
import 'alerts_tab.dart';
import 'lecturer_history_tab.dart';
import 'lecturer_intraday_tab.dart';
import 'lecturer_profile_tab.dart';
import 'lecturer_schedule_tab.dart';
import 'pigeonhole_tab.dart';

/// The lecturer app's navigation shell — same shared shell design as
/// the student's HomeShell (docs/PRD.md §7.3: "Shared app shell
/// ('SmartAttendance'), same platform, role-specific content"): a top
/// nav bar (Schedule / Intraday / Pigeonhole) and a bottom nav bar
/// (Alerts / History / Profile). Pigeonhole and Alerts are
/// role-agnostic per the PRD table, so they reuse the student tabs
/// as-is; Schedule, Intraday, History, and Profile carry
/// lecturer-specific content and data.
class LecturerHomeShell extends StatefulWidget {
  const LecturerHomeShell({super.key});

  @override
  State<LecturerHomeShell> createState() => _LecturerHomeShellState();
}

const _topLabels = ['Schedule', 'Intraday', 'Pigeonhole'];

class _LecturerHomeShellState extends State<LecturerHomeShell> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  LecturerProfile? _profile;
  List<TimetableEntry> _entries = [];
  bool _loading = true;
  String? _error;

  // 0-2 = the top nav bar's sections, 3-5 = the bottom nav bar's.
  int _selectedIndex = 0;

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
        lecturerId: profile.lecturerId,
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

  Future<void> _openRegistration() async {
    final profile = _profile;
    if (profile == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UnitRegistrationScreen(profile: profile),
      ),
    );

    // Registering/releasing a unit changes what this shell's own
    // timetable fetch should return, so refresh on return.
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final onTopTab = _selectedIndex <= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          onTopTab ? _topLabels[_selectedIndex] : _bottomTitle(_selectedIndex),
        ),
        actions: [
          IconButton(
            onPressed: _profile == null ? null : _openRegistration,
            icon: const Icon(Icons.add_task),
            tooltip: 'Register units you teach',
          ),
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Schedule')),
                ButtonSegment(value: 1, label: Text('Intraday')),
                ButtonSegment(value: 2, label: Text('Pigeonhole')),
              ],
              selected: onTopTab ? {_selectedIndex} : const {},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                setState(() => _selectedIndex = selection.first);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _load, child: _buildBody()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: onTopTab ? 0 : _selectedIndex - 3,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = 3 + index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _bottomTitle(int index) {
    switch (index) {
      case 3:
        return 'Alerts';
      case 4:
        return 'History';
      default:
        return 'Profile';
    }
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

    switch (_selectedIndex) {
      case 0:
        return LecturerScheduleTab(profile: _profile, entries: _entries);
      case 1:
        return LecturerIntradayTab(entries: _entries);
      case 2:
        return const PigeonholeTab();
      case 3:
        return const AlertsTab();
      case 4:
        return const LecturerHistoryTab();
      default:
        return LecturerProfileTab(
          profile: _profile,
          onRegisterUnits: _openRegistration,
        );
    }
  }
}
