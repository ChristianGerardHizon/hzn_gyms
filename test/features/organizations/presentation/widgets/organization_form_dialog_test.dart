import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/widgets/organization_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('OrganizationFormDialog', () {
    Future<void> openDialog(
      WidgetTester tester, {
      Organization? organization,
    }) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => showOrganizationFormDialog(
                        context,
                        organization: organization,
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('requires name and slug', (tester) async {
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

    testWidgets('renders inside Dialog and shrink-wraps on desktop', (
      tester,
    ) async {
      const org = Organization(
        id: 'org-1',
        name: 'Kylie Gym',
        slug: 'kyliegym',
      );

      await openDialog(tester, organization: org);

      expect(find.text('Edit Organization'), findsOneWidget);
      expect(find.text('Kylie Gym'), findsWidgets);

      // One Dialog from showConstrainedDialog — not a bare transparent overlay.
      expect(find.byType(Dialog), findsOneWidget);

      final column = tester.widget<Column>(
        find
            .descendant(
              of: find.byType(OrganizationFormDialog),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(column.mainAxisSize, MainAxisSize.min);

      final dialogSize = tester.getSize(find.byType(OrganizationFormDialog));
      expect(dialogSize.height, lessThan(800));
    });

    testWidgets('create mode shows create title inside Dialog', (tester) async {
      await openDialog(tester);

      expect(find.text('Create Organization'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('returns null when dismissed via Cancel', (tester) async {
      Future<bool?>? dialogFuture;

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () {
                        dialogFuture = showOrganizationFormDialog(context);
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Create Organization'), findsOneWidget);
      expect(dialogFuture, isNotNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await dialogFuture, isNull);
    });
  });
}
