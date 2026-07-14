import 'package:ebe_gym/src/features/memberships/domain/membership.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/memberships_controller.dart';
import 'package:ebe_gym/src/features/memberships/presentation/widgets/purchase_membership_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('PurchaseMembershipDialog', () {
    testWidgets('guest mode shows Walk-in title not Cashier', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            membershipsControllerProvider.overrideWith(
              () => _FakeMembershipsController([
                buildMembership(
                  name: 'NEW RATE WALK-IN REGULAR',
                  durationDays: 1,
                  price: 100,
                  memberNotRequired: true,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PurchaseMembershipDialog(guestMode: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Walk-in'), findsOneWidget);
      expect(find.text('Cashier'), findsNothing);
      expect(find.text('Day pass — name and plan only'), findsOneWidget);
      expect(find.text('Select a walk-in plan'), findsOneWidget);
    });
  });
}

class _FakeMembershipsController extends MembershipsController {
  _FakeMembershipsController(this._plans);

  final List<Membership> _plans;

  @override
  Future<List<Membership>> build() async => _plans;
}
