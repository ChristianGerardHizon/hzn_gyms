import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/widgets/cached_avatar.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';

void main() {
  const orgWithLogo = Organization(
    id: 'org-logo',
    name: 'Kylie Gym',
    slug: 'kyliegym',
    logoTransparentUrl: 'https://example.com/org-logo.png',
  );

  testWidgets('shows person icon when member photo and org logo are missing',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentOrganizationControllerProvider.overrideWith(
            () => _FixedCurrentOrganization(null),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CachedImage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('shows organization logo when member photo is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentOrganizationControllerProvider.overrideWith(
            () => _FixedCurrentOrganization(orgWithLogo),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CachedImage(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final cachedImages = tester.widgetList<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(cachedImages.length, 1);
    expect(cachedImages.first.imageUrl, orgWithLogo.logoTransparentUrl);
  });
}

class _FixedCurrentOrganization extends CurrentOrganizationController {
  _FixedCurrentOrganization(this._org);

  final Organization? _org;

  @override
  Future<Organization?> build() async => _org;
}
