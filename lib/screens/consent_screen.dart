import 'package:flutter/material.dart';

import '../models/consent.dart';
import '../services/api_client.dart';
import '../services/session_expiry.dart';
import '../services/session_store.dart';

/// Shown before a student's face can be enrolled: the full consent
/// notice, then an explicit "I agree" that records consent against
/// that notice's version. Pops `true` once consent is recorded and
/// `false` if the student declines or backs out — declining is a real
/// option (the notice says so), not a dead end that nags.
class ConsentScreen extends StatefulWidget {
  final ConsentInfo info;

  const ConsentScreen({super.key, required this.info});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  bool _agreed = false;
  bool _submitting = false;
  String? _error;

  Future<void> _agree() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final token = await _sessionStore.token;

    if (token == null) {
      if (!mounted) return;
      await handleUnauthorized(context);
      return;
    }

    try {
      await _apiClient.grantConsent(widget.info.notice.version, token);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (error.status == 401) {
        if (!mounted) return;
        await handleUnauthorized(context);
        return;
      }

      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.info.notice;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(notice.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (widget.info.status.needsReconsent) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'This notice has changed since you last agreed to it, '
                      'so we need to ask you again.',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Before we enroll your face, please read how it will be '
                  'used.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Data controller: ${notice.controller}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                for (final section in notice.sections) ...[
                  Text(
                    section.heading,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(section.body),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Questions or requests about your data: ${notice.contact}.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _agreed,
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _agreed = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'I have read this and I agree to my face being enrolled '
                    'for campus access and class attendance.',
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                FilledButton(
                  onPressed: _agreed && !_submitting ? _agree : null,
                  child: _submitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text('I agree and continue'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('No thanks'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
