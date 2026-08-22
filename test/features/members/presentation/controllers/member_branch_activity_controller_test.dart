import 'package:kylie_gym/src/features/members/presentation/controllers/member_branch_activity_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('memberBranchActivityIdsKey', () {
    test('returns empty string for no ids', () {
      expect(memberBranchActivityIdsKey([]), '');
    });

    test('sorts ids for stable provider keys', () {
      expect(
        memberBranchActivityIdsKey(['b', 'a', 'c']),
        'a,b,c',
      );
    });

    test('single id returns itself', () {
      expect(memberBranchActivityIdsKey(['member-1']), 'member-1');
    });
  });
}
