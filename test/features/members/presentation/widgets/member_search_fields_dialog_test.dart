import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/features/members/presentation/controllers/member_search_controller.dart';
import 'package:ebe_gym/src/features/members/presentation/widgets/dialogs/member_search_fields_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Reset restores default member search field checkboxes', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const Dialog(
                          child: MemberSearchFieldsDialog(),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MemberSearchFieldsDialog)),
    );
    container.read(memberSearchFieldsProvider.notifier).toggleField('email');
    await tester.pumpAndSettle();

    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('email-true')),
      ).value,
      isTrue,
    );

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('email-false')),
      ).value,
      isFalse,
    );
    expect(
      container.read(memberSearchFieldsProvider),
      defaultMemberSearchFields,
    );
  });
}
