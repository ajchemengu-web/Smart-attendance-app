import 'package:flutter/material.dart';

import '../../models/student_profile.dart';

/// docs/PRD.md §7.3's Profile fields. Unit registration, Residence,
/// and Contacts aren't collected by the backend's students table
/// yet — shown as "not collected yet" rather than a fake blank field,
/// same honesty as the ComingSoon tabs. Officially enrolled similarly
/// has no backing column; face_enrolled (a real field, just not one
/// this PRD section originally named) is shown instead, since it's
/// the actual precondition for being recognized anywhere in the
/// system.
class ProfileTab extends StatelessWidget {
  final StudentProfile? profile;
  final VoidCallback onEnrollFace;

  const ProfileTab({
    super.key,
    required this.profile,
    required this.onEnrollFace,
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
          subtitle: Text('Admission No. ${profile.admissionNumber}'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.school_outlined),
          title: Text(profile.course ?? 'Course not assigned yet'),
          subtitle: Text(
            [
              if (profile.department != null) profile.department,
              if (profile.year != null) 'Year ${profile.year}',
              if (profile.semester != null) 'Semester ${profile.semester}',
            ].join(' · '),
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            profile.faceEnrolled
                ? Icons.face_retouching_natural
                : Icons.face,
            color: profile.faceEnrolled ? Colors.green : null,
          ),
          title: Text(
            profile.faceEnrolled ? 'Face enrolled' : 'Face not enrolled yet',
          ),
          subtitle: const Text(
            'What lets you be recognized at SmartAccess checkpoints.',
          ),
          trailing: TextButton(
            onPressed: onEnrollFace,
            child: Text(profile.faceEnrolled ? 'Re-enroll' : 'Enroll'),
          ),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.home_outlined),
          title: Text('Residence'),
          subtitle: Text('Not collected yet.'),
        ),
        const ListTile(
          leading: Icon(Icons.phone_outlined),
          title: Text('Contacts'),
          subtitle: Text('Not collected yet.'),
        ),
        const ListTile(
          leading: Icon(Icons.menu_book_outlined),
          title: Text('Unit registration'),
          subtitle: Text('Not collected yet — admin-controlled.'),
        ),
      ],
    );
  }
}
