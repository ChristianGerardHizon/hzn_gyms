import 'package:hzn_gyms/src/features/members/presentation/controllers/member_active_branch_filter_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  group('MemberActiveBranchFilter', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('defaults to null (All)', () {
      expect(container.read(memberActiveBranchFilterProvider), isNull);
    });

    test('setBranchId updates state', () {
      container
          .read(memberActiveBranchFilterProvider.notifier)
          .setBranchId('branch-1');

      expect(container.read(memberActiveBranchFilterProvider), 'branch-1');
    });

    test('setBranchId with empty string clears to null', () {
      final notifier =
          container.read(memberActiveBranchFilterProvider.notifier);
      notifier.setBranchId('branch-1');
      notifier.setBranchId('');

      expect(container.read(memberActiveBranchFilterProvider), isNull);
    });

    test('clear resets to null', () {
      final notifier =
          container.read(memberActiveBranchFilterProvider.notifier);
      notifier.setBranchId('branch-1');
      notifier.clear();

      expect(container.read(memberActiveBranchFilterProvider), isNull);
    });

    test('setBranchId is a no-op when unchanged', () {
      final notifier =
          container.read(memberActiveBranchFilterProvider.notifier);
      notifier.setBranchId('branch-1');

      var notifications = 0;
      final sub = container.listen(
        memberActiveBranchFilterProvider,
        (_, __) => notifications++,
      );
      addTearDown(sub.close);

      notifier.setBranchId('branch-1');
      expect(notifications, 0);
    });
  });
}
