import 'package:hzn_gyms/src/core/widgets/branch_code_pill.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch_color_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const branch = Branch(
    id: 'branch-1',
    name: 'Bacolod Branch',
    code: 'bcd',
    address: 'x',
    contactNumber: '1',
    color: 'teal',
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
    expect(pill.color, BranchColorPreset.teal.color);
  });

  test('fromBranches prefers explicit color override', () {
    const override = Color(0xFFABCDEF);
    final pill = BranchCodePill.fromBranches(
      branchId: 'branch-1',
      branches: const [branch],
      color: override,
    );

    expect(pill!.color, override);
  });

  test('fromBranches returns null for empty id', () {
    expect(
      BranchCodePill.fromBranches(branchId: '', branches: const [branch]),
      isNull,
    );
  });

  test('branchLabelMaps builds code, name, and color maps', () {
    final maps = branchLabelMaps(const [branch]);
    expect(maps.codeById['branch-1'], 'BCD');
    expect(maps.nameById['branch-1'], 'Bacolod Branch');
    expect(maps.colorById['branch-1'], 'teal');
  });

  test('branchLabelMaps omits blank colors', () {
    const plain = Branch(
      id: 'branch-2',
      name: 'Talisay Branch',
      code: 'tal',
      address: 'y',
      contactNumber: '2',
    );
    final maps = branchLabelMaps(const [plain]);
    expect(maps.colorById.containsKey('branch-2'), isFalse);
  });
}
