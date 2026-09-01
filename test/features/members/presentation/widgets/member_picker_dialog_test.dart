import 'package:hzn_gyms/src/features/members/presentation/widgets/member_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberPickerDialog', () {
    testWidgets('shows search prompt and optional create flag in empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 700,
                child: MemberPickerDialog(
                  title: 'Search Member',
                  subtitle: 'Search all branches',
                  allowCreateOnEmpty: true,
                  showBranchActivity: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Search Member'), findsOneWidget);
      expect(find.text('Search all branches'), findsOneWidget);
      expect(
        find.text('Type a name or phone number to find a member'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does not show create plus when allowCreateOnEmpty is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 700,
                child: const MemberPickerDialog(),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsNothing);
    });
    testWidgets('prompts for minimum query length before searching', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 700,
                child: const MemberPickerDialog(),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Type at least 2 characters to search'), findsOneWidget);
    });

    testWidgets('focuses the search input when opened', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 700,
                child: const MemberPickerDialog(title: 'Search Member'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });
  });
}
