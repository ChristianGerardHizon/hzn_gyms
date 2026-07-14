import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/dashboard_members_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/dashboard_members_page_errors.dart';

void main() {
  group('isProviderDisposedDuringLoading', () {
    test('matches Riverpod dispose-during-loading StateError', () {
      final error = StateError(
        'The provider dashboardMembersPageProvider(page: 2, '
        'searchQuery: null, statusFilter: MemberStatusFilter.all) was '
        'disposed during loading state, yet no value could be emitted.',
      );
      expect(isProviderDisposedDuringLoading(error), isTrue);
    });

    test('rejects unrelated errors', () {
      expect(isProviderDisposedDuringLoading(StateError('other')), isFalse);
      expect(isProviderDisposedDuringLoading(Exception('nope')), isFalse);
    });
  });

  group('canCommitDashboardMembersPrefetch', () {
    test('allows commit when mounted and generation matches', () {
      expect(
        canCommitDashboardMembersPrefetch(
          requestGeneration: 2,
          currentGeneration: 2,
          isMounted: true,
        ),
        isTrue,
      );
    });

    test('blocks commit after unmount or superseded generation', () {
      expect(
        canCommitDashboardMembersPrefetch(
          requestGeneration: 2,
          currentGeneration: 2,
          isMounted: false,
        ),
        isFalse,
      );
      expect(
        canCommitDashboardMembersPrefetch(
          requestGeneration: 1,
          currentGeneration: 2,
          isMounted: true,
        ),
        isFalse,
      );
    });
  });

  group('isUsedAfterDisposeError', () {
    test('matches Flutter disposed ValueNotifier message', () {
      expect(
        isUsedAfterDisposeError(
          FlutterError(
            'A ValueNotifier<List<DashboardMember>> was used after being '
            'disposed.\nOnce you have called dispose() on a '
            'ValueNotifier<List<DashboardMember>>, it can no longer be used.',
          ),
        ),
        isTrue,
      );
      expect(isUsedAfterDisposeError(Exception('other')), isFalse);
    });
  });

  group('DashboardMembersPage', () {
    test('hasMore when page is below totalPages', () {
      const page = DashboardMembersPage(
        items: [],
        totalItems: 40,
        page: 1,
        totalPages: 2,
      );
      expect(page.hasMore, isTrue);
      expect(
        const DashboardMembersPage(
          items: [],
          totalItems: 20,
          page: 2,
          totalPages: 2,
        ).hasMore,
        isFalse,
      );
    });
  });
}
