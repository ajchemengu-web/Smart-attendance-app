import 'package:flutter/material.dart';

import '../../models/lecturer_profile.dart';

/// docs/PRD.md §7.2: "Lecturer profile section is distinct from the
/// student profile." Unlike a student's profile, unit registration
/// here IS self-service (unit_registration_screen.dart) — a lecturer
/// claims the units they teach themselves, rather than an admin
/// assigning them.
class LecturerProfileTab extends StatelessWidget {
  final LecturerProfile? profile;
  final VoidCallback onRegisterUnits;

  const LecturerProfileTab({
    super.key,
    required this.profile,
    required this.onRegisterUnits,
  });

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;

    if (profile == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Could not load your profile.'),
        ),
      );
    }

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: Text(profile.fullName),
          subtitle: Text('Lecturer ID: ${profile.lecturerId}'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.apartment_outlined),
          title: Text(profile.department ?? 'Department not assigned yet'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.add_task),
          title: const Text('Units you teach'),
          subtitle: const Text(
            'Self-service — claim or release the units assigned to you.',
          ),
          trailing: TextButton(
            onPressed: onRegisterUnits,
            child: const Text('Manage'),
          ),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.phone_outlined),
          title: Text('Contacts'),
          subtitle: Text('Not collected yet.'),
        ),
      ],
    );
  }
}
