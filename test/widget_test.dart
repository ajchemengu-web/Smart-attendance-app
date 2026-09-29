import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_attendance/models/consent.dart';
import 'package:smart_attendance/screens/consent_screen.dart';
import 'package:smart_attendance/screens/login_screen.dart';

void main() {
  testWidgets('Login screen shows username/password fields and a sign-in button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  group('ConsentScreen', () {
    ConsentInfo info({bool needsReconsent = false}) => ConsentInfo(
      notice: ConsentNotice(
        version: '2026-09-v1',
        title: 'Facial recognition consent',
        controller: 'Example University',
        contact: 'dpo@example.ac.ke',
        sections: [
          NoticeSection(heading: 'What we collect', body: 'A face template.'),
          NoticeSection(
            heading: 'Your choice and your rights',
            body: 'You do not have to agree.',
          ),
        ],
      ),
      status: ConsentStatus(
        consentActive: false,
        needsReconsent: needsReconsent,
        grantedAt: null,
        currentNoticeVersion: '2026-09-v1',
      ),
    );

    Finder agreeButton() => find.widgetWithText(FilledButton, 'I agree and continue');

    testWidgets('shows the notice and keeps "I agree" disabled until ticked',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ConsentScreen(info: info())));

      expect(find.text('What we collect'), findsOneWidget);
      expect(find.text('You do not have to agree.'), findsOneWidget);
      expect(find.textContaining('Example University'), findsOneWidget);

      expect(tester.widget<FilledButton>(agreeButton()).onPressed, isNull);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(tester.widget<FilledButton>(agreeButton()).onPressed, isNotNull);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(tester.widget<FilledButton>(agreeButton()).onPressed, isNull);
    });

    testWidgets('explains a changed notice when consent needs re-asking',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ConsentScreen(info: info(needsReconsent: true))),
      );

      expect(find.textContaining('has changed since you last agreed'),
          findsOneWidget);
    });

    testWidgets('declining pops false without agreeing to anything',
        (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ConsentScreen(info: info()),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No thanks'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
