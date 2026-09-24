import 'package:flutter/material.dart';

import '../../models/student_profile.dart';
import '../../models/timetable_entry.dart';
import '../../services/api_client.dart';
import '../../services/session_expiry.dart';
import '../../services/session_store.dart';
import '../face_enrollment_screen.dart';
import '../login_screen.dart';
import 'alerts_tab.dart';
import 'history_tab.dart';
import 'intraday_tab.dart';
import 'pigeonhole_tab.dart';
import 'profile_tab.dart';
import 'schedule_tab.dart';

/// The student app's navigation shell (docs/PRD.md §7.3): a top nav
/// bar (Schedule / Intraday / Pigeonhole) and a bottom nav bar
/// (Alerts / History / Profile) — six sections total, arranged as
/// two groups of three rather than flat top-level tabs. Fetches
/// profile + timetable once here rather than per-tab, since Schedule
/// and Intraday both read the same data.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

const _topLabels = ['Schedule', 'Intraday', 'Pigeonhole'];

class _HomeShellState extends State<HomeShell> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  StudentProfile? _profile;
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
      body: Column(
        children: [
          if (!_loading && _profile != null && !_profile!.faceEnrolled)
            _FaceEnrollmentBanner(onTap: _goToFaceEnrollment),
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
        return ScheduleTab(profile: _profile, entries: _entries);
      case 1:
        return IntradayTab(entries: _entries);
      case 2:
        return const PigeonholeTab();
      case 3:
        return const AlertsTab();
      case 4:
        return const HistoryTab();
      default:
        return ProfileTab(profile: _profile, onEnrollFace: _goToFaceEnrollment);
    }
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
