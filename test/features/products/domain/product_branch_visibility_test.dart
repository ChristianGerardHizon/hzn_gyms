import 'package:hzn_gyms/src/features/products/domain/product_branch_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isProductVisibleForBranch', () {
    test('visible when viewing all branches', () {
      expect(
        isProductVisibleForBranch(
          productBranchId: 'branch-a',
          currentBranchId: 'branch-b',
          viewingAllBranches: true,
        ),
        isTrue,
      );
    });

    test('visible when no current branch is selected', () {
      expect(
        isProductVisibleForBranch(
          productBranchId: 'branch-a',
          currentBranchId: null,
          viewingAllBranches: false,
        ),
        isTrue,
      );
    });

    test('visible when branch IDs match', () {
      expect(
        isProductVisibleForBranch(
          productBranchId: 'branch-a',
          currentBranchId: 'branch-a',
          viewingAllBranches: false,
        ),
        isTrue,
      );
    });

    test('hidden when branch IDs differ', () {
      expect(
        isProductVisibleForBranch(
          productBranchId: 'branch-a',
          currentBranchId: 'branch-b',
          viewingAllBranches: false,
        ),
        isFalse,
      );
    });

    test('hidden when product branch is null and a concrete branch is selected',
        () {
      expect(
        isProductVisibleForBranch(
          productBranchId: null,
          currentBranchId: 'branch-a',
          viewingAllBranches: false,
        ),
        isFalse,
      );
    });
  });

  group('shouldProceedWithBranchMismatchRedirect', () {
    test('false when cancelled even if still hidden', () {
      expect(
        shouldProceedWithBranchMismatchRedirect(
          cancelled: true,
          productBranchId: 'branch-a',
          currentBranchId: 'branch-b',
          viewingAllBranches: false,
        ),
        isFalse,
      );
    });

    test('false when product became visible before callback', () {
      expect(
        shouldProceedWithBranchMismatchRedirect(
          cancelled: false,
          productBranchId: 'branch-a',
          currentBranchId: 'branch-a',
          viewingAllBranches: false,
        ),
        isFalse,
      );
    });

    test('true when still hidden and not cancelled', () {
      expect(
        shouldProceedWithBranchMismatchRedirect(
          cancelled: false,
          productBranchId: 'branch-a',
          currentBranchId: 'branch-b',
          viewingAllBranches: false,
        ),
        isTrue,
      );
    });
  });
}
