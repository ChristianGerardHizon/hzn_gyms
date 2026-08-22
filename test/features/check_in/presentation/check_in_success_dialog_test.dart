import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/core/widgets/cached_avatar.dart';
import 'package:kylie_gym/src/features/check_in/presentation/widgets/check_in_success_dialog.dart';

void main() {
  testWidgets('success dialog shows member photo avatar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  showCheckInSuccessDialog(
                    context,
                    memberName: 'Jane Doe',
                    hasActiveMembership: true,
                    membershipName: 'Monthly Plan',
                    membershipEndDate: DateTime(2026, 12, 31),
                    membershipDaysRemaining: 30,
                    memberPhotoUrl: 'https://example.com/jane.jpg',
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(find.text('Check-In Successful'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);

    final avatar = tester.widget<CachedAvatar>(find.byType(CachedAvatar));
    expect(avatar.imageUrl, 'https://example.com/jane.jpg');
    expect(avatar.radius, 48);

    // Advance past auto-close timer so the test does not hang.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('success dialog shows placeholder avatar when photo is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  showCheckInSuccessDialog(
                    context,
                    memberName: 'Jane Doe',
                    hasActiveMembership: true,
                    membershipEndDate: DateTime(2026, 12, 31),
                    membershipDaysRemaining: 30,
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    final avatar = tester.widget<CachedAvatar>(find.byType(CachedAvatar));
    expect(avatar.imageUrl, isNull);

    await tester.pump(const Duration(seconds: 5));
  });
}
