import 'package:ebe_gym/src/features/members/domain/member_active_branch_list_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('buildActiveMembersAtBranchViewFilter', () {
    final now = DateTime(2026, 8, 3, 15, 30);

    test('returns null when planIds is empty', () {
      expect(
        buildActiveMembersAtBranchViewFilter(planIds: const [], now: now),
        isNull,
      );
    });

    test('returns null when planIds are blank', () {
      expect(
        buildActiveMembersAtBranchViewFilter(planIds: const ['', ''], now: now),
        isNull,
      );
    });

    test('includes plan OR clause, active status, and date bound', () {
      final filter = buildActiveMembersAtBranchViewFilter(
        planIds: const ['plan-a', 'plan-b'],
        now: now,
      );

      expect(filter, isNotNull);
      expect(
        filter,
        contains('(membershipId = "plan-a" || membershipId = "plan-b")'),
      );
      expect(filter, contains("membershipStatus = 'active'"));
      expect(filter, contains("expirationDate >= '"));
      // Start of local day 2026-08-03 as UTC ISO via toPocketBaseUtc
      expect(filter, contains('2026-08-0'));
    });

    test('dedupes plan ids', () {
      final filter = buildActiveMembersAtBranchViewFilter(
        planIds: const ['plan-a', 'plan-a'],
        now: now,
      );

      expect(filter, isNotNull);
      expect(
        'membershipId = "plan-a"'.allMatches(filter!).length,
        1,
      );
    });

    test('adds search tokens when searchQuery is set', () {
      final filter = buildActiveMembersAtBranchViewFilter(
        planIds: const ['plan-a'],
        now: now,
        searchQuery: 'Jane',
      );

      expect(filter, contains("name ~ 'Jane'"));
      expect(filter, contains("mobileNumber ~ 'Jane'"));
    });
  });

  group('activeBranchMembersSortString', () {
    test('uses name ascending by default for unsupported fields', () {
      expect(
        activeBranchMembersSortString(field: 'email', descending: false),
        'name',
      );
    });

    test('allows name and mobileNumber with direction', () {
      expect(
        activeBranchMembersSortString(field: 'name', descending: true),
        '-name',
      );
      expect(
        activeBranchMembersSortString(
          field: 'mobileNumber',
          descending: false,
        ),
        'mobileNumber',
      );
    });
  });

  group('memberFromMembershipStatusView', () {
    test('maps core fields and builds members photo URL', () {
      final record = RecordModel({
        'id': 'member-1',
        'collectionId': 'view_col',
        'collectionName': 'membersWithMembershipStatus',
        'name': 'Jane Doe',
        'photo': 'avatar.jpg',
        'mobileNumber': '09171234567',
      });

      final member = memberFromMembershipStatusView(
        record,
        baseUrl: 'https://pb.example',
      );

      expect(member.id, 'member-1');
      expect(member.name, 'Jane Doe');
      expect(member.mobileNumber, '09171234567');
      expect(
        member.photo,
        'https://pb.example/api/files/members/member-1/avatar.jpg',
      );
    });

    test('omits empty photo and mobile', () {
      final record = RecordModel({
        'id': 'member-2',
        'name': 'No Photo',
        'photo': '',
        'mobileNumber': '',
      });

      final member = memberFromMembershipStatusView(
        record,
        baseUrl: 'https://pb.example',
      );

      expect(member.photo, isNull);
      expect(member.mobileNumber, isNull);
    });
  });
}
