import 'package:ebe_gym/src/features/members/presentation/widgets/member_branch_activity_chips.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_branch_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty activity renders muted None chip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MemberBranchActivityChips(
            activity: MemberBranchActivity(branchIds: {}),
            branchCodeById: {},
            branchNameById: {},
          ),
        ),
      ),
    );

    expect(find.text('None'), findsOneWidget);
    expect(find.byIcon(Icons.location_off_outlined), findsOneWidget);

    final text = tester.widget<Text>(find.text('None'));
    expect(text.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('dense empty chip uses smaller type', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MemberBranchActivityChips(
            activity: MemberBranchActivity(branchIds: {}),
            branchCodeById: {},
            branchNameById: {},
            dense: true,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('None'));
    expect(text.style?.fontSize, 10);
  });

  testWidgets('renders All when activity covers every branch', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MemberBranchActivityChips(
            activity: MemberBranchActivity(branchIds: {'b1', 'b2'}),
            branchCodeById: {'b1': 'BCD', 'b2': 'TAL'},
            branchNameById: {'b1': 'Bacolod', 'b2': 'Talisay'},
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
  });
}
