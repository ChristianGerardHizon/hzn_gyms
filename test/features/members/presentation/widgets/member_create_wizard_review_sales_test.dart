import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:ebe_gym/src/features/memberships/domain/membership.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/membership_add_ons_controller.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/memberships_controller.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:ebe_gym/src/features/memberships/domain/membership_add_on.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Member create wizard review sales checkbox', () {
    testWidgets(
      'shows Exclude from sales unchecked by default when plan selected',
      (tester) async {
        await _pumpWizard(
          tester,
          plans: [buildMembership(name: 'Monthly')],
        );

        await _completeDetailsStep(tester);
        // Skip photo
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        // Skip card
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        // Select membership plan
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Exclude from sales'), findsOneWidget);
        expect(
          find.text('Create membership without a sale or payment'),
          findsOneWidget,
        );

        final checkbox = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(checkbox.value, isFalse);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Save (no sale)'), findsNothing);

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isTrue,
        );
        expect(find.text('Save (no sale)'), findsOneWidget);
      },
    );

    testWidgets(
      'hides Exclude from sales when no membership is selected',
      (tester) async {
        await _pumpWizard(tester, plans: [buildMembership(name: 'Monthly')]);

        await _completeDetailsStep(tester);
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Exclude from sales'), findsNothing);
        expect(find.text('No membership selected'), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpWizard(
  WidgetTester tester, {
  required List<Membership> plans,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
          membershipsControllerProvider.overrideWith(
            () => _FakeMembershipsController(plans),
          ),
          membershipAddOnsControllerProvider.overrideWith(
            () => _FakeMembershipAddOnsController(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MemberFormDialog(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _completeDetailsStep(WidgetTester tester) async {
  await tester.enterText(
    find.byType(FormBuilderTextField).first,
    'Jane Doe',
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

class _FakeMembershipsController extends MembershipsController {
  _FakeMembershipsController(this._plans);

  final List<Membership> _plans;

  @override
  Future<List<Membership>> build() async => _plans;
}

class _FakeMembershipAddOnsController extends MembershipAddOnsController {
  @override
  Future<List<MembershipAddOn>> build(String membershipId) async => const [];
}
