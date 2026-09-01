import 'package:kylie_gym/src/core/i18n/strings.g.dart';
import 'package:kylie_gym/src/features/members/data/local/member_local_data_source.dart';
import 'package:kylie_gym/src/features/members/data/repositories/member_repository.dart';
import 'package:kylie_gym/src/features/members/domain/member.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership_add_on.dart';
import 'package:kylie_gym/src/features/memberships/presentation/controllers/membership_add_ons_controller.dart';
import 'package:kylie_gym/src/features/memberships/presentation/controllers/membership_purchase_catalog_provider.dart';
import 'package:kylie_gym/src/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:kylie_gym/src/features/settings/domain/branch.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

const _testBranch = Branch(
  id: 'branch-1',
  name: 'Main Branch',
  code: 'MAIN',
  address: '123 Gym St',
  contactNumber: '555-0100',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Member create wizard card step', () {
    testWidgets('shows Card step after Photo step', (tester) async {
      await _pumpWizard(tester);

      await _completeDetailsStep(tester);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Add a Card'), findsOneWidget);
      expect(find.text('Card'), findsWidgets);
    });

    testWidgets('skip on Card step advances to Membership', (tester) async {
      await _pumpWizard(tester);

      await _completeDetailsStep(tester);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('No card added'), findsNothing);
      expect(find.text('No membership selected'), findsNothing);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('manual card entry appears on Review step', (tester) async {
      await _pumpWizard(tester);

      await _completeDetailsStep(tester);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enter Card ID manually'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'ABCD1234');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('ID Card'), findsOneWidget);
      expect(find.text('ABCD1234'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}

Future<void> _pumpWizard(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final local = MockMemberLocalDataSource();
  final repo = MockMemberRepository();
  when(
    () => local.searchQuick(
      any(),
      fields: any(named: 'fields'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => <Member>[]);
  when(
    () => repo.searchQuick(
      any(),
      fields: any(named: 'fields'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => right(<Member>[]));

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
          currentBranchIdProvider.overrideWithValue('branch-1'),
          memberLocalDataSourceProvider.overrideWithValue(local),
          memberRepositoryProvider.overrideWithValue(repo),
          branchesControllerProvider.overrideWith(
            () => _FakeBranchesController(const [_testBranch]),
          ),
          membershipPurchaseCatalogProvider(false).overrideWith(
            (ref) async => const [],
          ),
          membershipPurchaseCatalogProvider(true).overrideWith(
            (ref) async => const [],
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
  final fields = find.byType(FormBuilderTextField);
  await tester.enterText(fields.at(0), 'Jane Doe');
  await tester.enterText(fields.at(1), '09171234567');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

class _FakeMembershipAddOnsController extends MembershipAddOnsController {
  @override
  Future<List<MembershipAddOn>> build(String membershipId) async => const [];
}
