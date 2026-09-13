import 'package:flutter/material.dart';

import '../models/lecturer_profile.dart';
import '../models/unit.dart';
import '../services/api_client.dart';
import '../services/session_expiry.dart';
import '../services/session_store.dart';

/// Lets a lecturer self-register the units they teach (docs/PRD.md
/// §6, §8): claiming a unit here is what sets its lecturer_id, which
/// is what LecturerScheduleScreen's own timetable fetch then matches
/// against — replacing the old design where a Timetabling Admin had
/// to type this lecturer's name onto every entry by hand.
class UnitRegistrationScreen extends StatefulWidget {
  final LecturerProfile profile;

  const UnitRegistrationScreen({super.key, required this.profile});

  @override
  State<UnitRegistrationScreen> createState() =>
      _UnitRegistrationScreenState();
}

class _UnitRegistrationScreenState extends State<UnitRegistrationScreen> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  List<Unit> _units = [];
  bool _loading = true;
  String? _error;
  int? _busyUnitId;

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
      final units = await _apiClient.getUnits(token);

      if (!mounted) return;

      setState(() => _units = units);
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

  Future<void> _toggleClaim(Unit unit) async {
    final token = await _sessionStore.token;
    if (token == null) return;

    setState(() => _busyUnitId = unit.id);

    try {
      if (unit.lecturerId == widget.profile.lecturerId) {
        await _apiClient.unclaimUnit(unit.id, token);
      } else {
        await _apiClient.claimUnit(unit.id, token);
      }
    } on ApiException catch (error) {
      if (error.status == 401) {
        if (!mounted) return;
        await handleUnauthorized(context);
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busyUnitId = null);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register the units you teach')),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
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

    if (_units.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No units exist yet — ask the Timetabling Admin to create '
              'them first.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _units.length,
      itemBuilder: (context, index) {
        final unit = _units[index];
        final isMine = unit.lecturerId == widget.profile.lecturerId;
        final isSomeoneElses = unit.lecturerId != null && !isMine;

        return ListTile(
          title: Text('${unit.unitCode} — ${unit.unitName}'),
          subtitle: Text(
            '${unit.course} · Year ${unit.year} · Sem ${unit.semester}'
            '${isSomeoneElses ? ' · claimed by another lecturer' : ''}',
          ),
          trailing: isSomeoneElses
              ? const Text('Unavailable', style: TextStyle(fontSize: 12))
              : TextButton(
                  onPressed: _busyUnitId == unit.id
                      ? null
                      : () => _toggleClaim(unit),
                  child: Text(isMine ? 'Release' : 'Claim'),
                ),
        );
      },
    );
  }
}
