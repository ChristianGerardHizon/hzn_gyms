import 'package:ebe_gym/src/core/sync/sync_status.dart';
import 'package:ebe_gym/src/features/members/domain/member.dart';
import 'package:ebe_gym/src/features/members/presentation/widgets/member_list_tile.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_branch_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('MemberListTile.buildSubtitle', () {
    test('returns trimmed phone when present', () {
      final member = buildMember(mobileNumber: ' 09810779830 ');
      expect(MemberListTile.buildSubtitle(member), '09810779830');
    });

    test('returns null when phone is missing or blank', () {
      expect(
        MemberListTile.buildSubtitle(buildMember(mobileNumber: null)),
        isNull,
      );
      expect(
        MemberListTile.buildSubtitle(buildMember(mobileNumber: '   ')),
        isNull,
      );
    });
  });

  testWidgets('renders name, phone, and empty activity chip', (tester) async {
    final member = buildMember(
      name: 'Ace Christian Erwin Honao',
      mobileNumber: '09810779830',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberListTile(
            member: member,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Ace Christian Erwin Honao'), findsOneWidget);
    expect(find.text('09810779830'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('shows full name in tooltip', (tester) async {
    const longName = 'Ace Christian Erwin Honao Extremely Long Name';
    final member = buildMember(
      name: longName,
      mobileNumber: '09810779830',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: MemberListTile(
              member: member,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final tooltip = tester.widget<Tooltip>(
      find.ancestor(
        of: find.textContaining('Ace Christian'),
        matching: find.byType(Tooltip),
      ),
    );
    expect(tooltip.message, longName);
  });

  testWidgets('invokes onTap when pressed', (tester) async {
    var tapped = false;
    final member = buildMember(name: 'Jane Doe', mobileNumber: '09123456789');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberListTile(
            member: member,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MemberListTile));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('lays out many branch chips in a narrow row without error', (
    tester,
  ) async {
    final member = buildMember(name: 'Jane Doe', mobileNumber: '09123456789');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: MemberListTile(
              member: member,
              onTap: () {},
              activity: const MemberBranchActivity(
                branchIds: {'b1', 'b2', 'b3', 'b4'},
              ),
              // Extra unused branch so activity is not treated as "All".
              branchCodeById: const {
                'b1': 'BCD',
                'b2': 'MNL',
                'b3': 'CEB',
                'b4': 'DVO',
                'b5': 'ILO',
              },
              branchNameById: const {
                'b1': 'Bacolod',
                'b2': 'Manila',
                'b3': 'Cebu',
                'b4': 'Davao',
                'b5': 'Iloilo',
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('BCD'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('phone and chips share a narrow row without overflow', (
    tester,
  ) async {
    final member = buildMember(
      name: 'Jane Doe',
      mobileNumber: '091234567890123',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: MemberListTile(
              member: member,
              onTap: () {},
              activity: const MemberBranchActivity(
                branchIds: {'b1', 'b2', 'b3'},
              ),
              branchCodeById: const {
                'b1': 'BCD',
                'b2': 'MNL',
                'b3': 'CEB',
                'b4': 'DVO',
              },
              branchNameById: const {
                'b1': 'Bacolod',
                'b2': 'Manila',
                'b3': 'Cebu',
                'b4': 'Davao',
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides activity chips when showBranchActivity is false', (
    tester,
  ) async {
    final member = buildMember(name: 'Jane Doe', mobileNumber: '09123456789');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberListTile(
            member: member,
            showBranchActivity: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('None'), findsNothing);
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets('shows pending sync icon when sync is pending', (tester) async {
    final member = Member(
      id: 'member-1',
      name: 'Jane Doe',
      mobileNumber: '09123456789',
      syncStatus: SyncStatus.pending,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberListTile(
            member: member,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
  });

  testWidgets('shows branch activity labels when activity is present', (
    tester,
  ) async {
    final member = buildMember(name: 'Jane Doe', mobileNumber: '09123456789');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberListTile(
            member: member,
            activity: const MemberBranchActivity(branchIds: {'b1'}),
            branchCodeById: const {'b1': 'BCD', 'b2': 'TAL'},
            branchNameById: const {
              'b1': 'Bacolod Branch',
              'b2': 'Talisay Branch',
            },
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('BCD'), findsOneWidget);
    expect(find.text('None'), findsNothing);
    expect(find.text('All'), findsNothing);
  });
}
