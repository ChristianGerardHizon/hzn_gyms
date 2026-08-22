import 'package:kylie_gym/src/core/i18n/strings.g.dart';
import 'package:kylie_gym/src/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership.dart';
import 'package:kylie_gym/src/features/memberships/presentation/controllers/memberships_controller.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
          membershipsControllerProvider.overrideWith(
            () => _FakeMembershipsController(const []),
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
