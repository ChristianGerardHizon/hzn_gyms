import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/widgets/form/form_dialog_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Save is disabled when saveEnabled is false', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: FormDialogHeader(
              title: 'Test',
              onClose: () {},
              onSave: (_) {},
              saveEnabled: false,
            ),
          ),
        ),
      ),
    );

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('Save is enabled when saveEnabled is true', (tester) async {
    var saved = false;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: FormDialogHeader(
              title: 'Test',
              onClose: () {},
              onSave: (_) => saved = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    expect(saved, isTrue);
  });
}
