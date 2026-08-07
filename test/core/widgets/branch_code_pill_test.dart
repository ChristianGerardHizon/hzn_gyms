import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const branch = Branch(
    id: 'branch-1',
    name: 'Bacolod Branch',
    code: 'bcd',
    address: 'x',
    contactNumber: '1',
  );

  testWidgets('renders code label with name tooltip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BranchCodePill(label: 'BCD', tooltip: 'Bacolod Branch'),
        ),
      ),
    );

    expect(find.text('BCD'), findsOneWidget);
    expect(
      find.byTooltip('Bacolod Branch'),
      findsOneWidget,
    );
  });

  test('fromBranches resolves pillLabel and name', () {
    final pill = BranchCodePill.fromBranches(
      branchId: 'branch-1',
      branches: const [branch],
    );

    expect(pill, isNotNull);
    expect(pill!.label, 'BCD');
    expect(pill.tooltip, 'Bacolod Branch');
  });

  test('fromBranches returns null for empty id', () {
    expect(
      BranchCodePill.fromBranches(branchId: '', branches: const [branch]),
      isNull,
    );
  });

  test('branchLabelMaps builds code and name maps', () {
    final maps = branchLabelMaps(const [branch]);
    expect(maps.codeById['branch-1'], 'BCD');
    expect(maps.nameById['branch-1'], 'Bacolod Branch');
  });
}
