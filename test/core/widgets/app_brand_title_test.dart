import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/widgets/app_brand_title.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';

void main() {
  const org = Organization(id: 'org-1', name: 'Test Gym', slug: 'testgym');

  Widget buildHarness({
    required Widget child,
    Organization? organization,
  }) {
    return TranslationProvider(
      child: ProviderScope(
        overrides: [
          currentOrganizationControllerProvider.overrideWith(
            () => _FakeCurrentOrganizationController(organization ?? org),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  testWidgets('renders compact logo and single-line title like Firebase',
      (tester) async {
    await tester.pumpWidget(
      buildHarness(child: const AppBrandTitle()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Gym'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Test Gym'));
    expect(title.maxLines, 1);
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w500);
  });

  testWidgets('logoOnly renders logo without title text', (tester) async {
    await tester.pumpWidget(
      buildHarness(child: const AppBrandTitle(logoOnly: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Gym'), findsNothing);
    expect(find.byType(AppBrandTitle), findsOneWidget);
  });
}

class _FakeCurrentOrganizationController extends CurrentOrganizationController {
  _FakeCurrentOrganizationController(this._organization);

  final Organization _organization;

  @override
  Future<Organization?> build() async => _organization;
}
