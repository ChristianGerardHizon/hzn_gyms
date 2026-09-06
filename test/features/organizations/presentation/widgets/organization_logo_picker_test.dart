import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_logo_draft.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/widgets/organization_logo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows upload action and existing logo preview', (tester) async {
    OrganizationLogoDraft? latestDraft;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: OrganizationLogoPicker(
              existingLogoUrl: 'https://example.com/logo.png',
              onChanged: (draft) => latestDraft = draft,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Organization Logo'), findsOneWidget);
    expect(find.text('Replace logo'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    await tester.pump();

    expect(latestDraft, isA<OrganizationLogoDraft>());
    expect(latestDraft!.removeExisting, isTrue);
  });
}
