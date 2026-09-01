import 'package:kylie_gym/src/core/i18n/strings.g.dart';
import 'package:kylie_gym/src/features/organizations/presentation/widgets/organization_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('requires name and slug', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TranslationProvider(
        child: const ProviderScope(
          child: MaterialApp(home: Scaffold(body: OrganizationFormDialog())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Slug *'), findsOneWidget);
  });
}
