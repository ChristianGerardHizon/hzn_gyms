import 'package:hzn_gyms/src/core/widgets/select_branch_for_action_dialog.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const branchA = Branch(
    id: 'branch-a',
    name: 'Bacolod Branch',
    code: 'BCD',
    address: 'x',
    contactNumber: '1',
    color: 'teal',
  );
  const branchB = Branch(
    id: 'branch-b',
    name: 'Talisay Branch',
    code: 'TAL',
    address: 'y',
    contactNumber: '2',
    color: 'orange',
  );

  testWidgets('shows message and branch pills', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SelectBranchForActionDialog(
            branches: [branchA, branchB],
            onConfirm: _noopConfirm,
          ),
        ),
      ),
    );

    expect(find.text('Select a Branch'), findsOneWidget);
    expect(find.textContaining('all branches'), findsOneWidget);
    expect(find.text('BCD'), findsOneWidget);
    expect(find.text('TAL'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Switch & continue'), findsOneWidget);
  });

  testWidgets('Switch & continue stays disabled until a pill is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SelectBranchForActionDialog(
            branches: [branchA, branchB],
            onConfirm: _noopConfirm,
          ),
        ),
      ),
    );

    final continueButton = find.widgetWithText(FilledButton, 'Switch & continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tester.tap(find.text('BCD'));
    await tester.pump();

    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('Cancel pops without calling onConfirm', (tester) async {
    var onConfirmCalled = false;
    String? dialogResult = 'unset';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                dialogResult = await showDialog<String>(
                  context: context,
                  builder: (_) => SelectBranchForActionDialog(
                    branches: const [branchA, branchB],
                    onConfirm: (id) async {
                      onConfirmCalled = true;
                    },
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(onConfirmCalled, isFalse);
    expect(dialogResult, isNull);
  });

  testWidgets('Switch & continue calls onConfirm and returns branch id', (
    tester,
  ) async {
    String? confirmedId;
    String? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                dialogResult = await showDialog<String>(
                  context: context,
                  builder: (_) => SelectBranchForActionDialog(
                    branches: const [branchA, branchB],
                    onConfirm: (id) async {
                      confirmedId = id;
                    },
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TAL'));
    await tester.pump();
    await tester.tap(find.text('Switch & continue'));
    await tester.pumpAndSettle();

    expect(confirmedId, 'branch-b');
    expect(dialogResult, 'branch-b');
  });

  testWidgets('ensureWritableBranch returns true when branch already set', (
    tester,
  ) async {
    late bool result;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectiveBranchIdForWriteProvider.overrideWithValue('branch-a'),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await ensureWritableBranch(context, ref);
                  },
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Select a Branch'), findsNothing);
  });

  testWidgets('ensureWritableBranch shows dialog when viewing all branches', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectiveBranchIdForWriteProvider.overrideWithValue(null),
          branchesControllerProvider.overrideWith(
            () => _FakeBranchesController(const [branchA, branchB]),
          ),
          currentBranchControllerProvider.overrideWith(
            () => _AllBranchesController(),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => ensureWritableBranch(context, ref),
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.text('Select a Branch'), findsOneWidget);
    expect(find.text('BCD'), findsOneWidget);
    expect(find.text('TAL'), findsOneWidget);
  });
}

Future<void> _noopConfirm(String _) async {}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

class _AllBranchesController extends CurrentBranchController {
  @override
  Future<CurrentBranchSelection> build() async {
    return const CurrentBranchSelection(isAll: true);
  }

  @override
  Future<List<String>> switchableBranchIds() async =>
      const ['branch-a', 'branch-b'];

  @override
  Future<void> switchBranch(String branchId) async {
    state = AsyncData(
      CurrentBranchSelection(
        branch: Branch(
          id: branchId,
          name: branchId,
          code: 'X',
          address: '',
          contactNumber: '',
        ),
      ),
    );
  }
}
