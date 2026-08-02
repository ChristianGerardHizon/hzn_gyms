// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_branch_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the current working branch.
///
/// - Admins: can switch to any branch or "All branches"; selection is persisted
/// - Non-admins: can switch among allowed branches; locked if only one

@ProviderFor(CurrentBranchController)
final currentBranchControllerProvider = CurrentBranchControllerProvider._();

/// Controller for managing the current working branch.
///
/// - Admins: can switch to any branch or "All branches"; selection is persisted
/// - Non-admins: can switch among allowed branches; locked if only one
final class CurrentBranchControllerProvider
    extends
        $AsyncNotifierProvider<
          CurrentBranchController,
          CurrentBranchSelection
        > {
  /// Controller for managing the current working branch.
  ///
  /// - Admins: can switch to any branch or "All branches"; selection is persisted
  /// - Non-admins: can switch among allowed branches; locked if only one
  CurrentBranchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBranchControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBranchControllerHash();

  @$internal
  @override
  CurrentBranchController create() => CurrentBranchController();
}

String _$currentBranchControllerHash() =>
    r'a6a9668b7c1721bac5a9abe218aeb27203663a1a';

/// Controller for managing the current working branch.
///
/// - Admins: can switch to any branch or "All branches"; selection is persisted
/// - Non-admins: can switch among allowed branches; locked if only one

abstract class _$CurrentBranchController
    extends $AsyncNotifier<CurrentBranchSelection> {
  FutureOr<CurrentBranchSelection> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CurrentBranchSelection>, CurrentBranchSelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CurrentBranchSelection>,
                CurrentBranchSelection
              >,
              AsyncValue<CurrentBranchSelection>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether admin is viewing all branches (no branch filter).

@ProviderFor(viewingAllBranches)
final viewingAllBranchesProvider = ViewingAllBranchesProvider._();

/// Whether admin is viewing all branches (no branch filter).

final class ViewingAllBranchesProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether admin is viewing all branches (no branch filter).
  ViewingAllBranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewingAllBranchesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewingAllBranchesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return viewingAllBranches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$viewingAllBranchesHash() =>
    r'f4c26c51c4a93794e3e1b61d2aad76687df52b5d';

/// Convenience provider for current branch ID.
///
/// Returns `null` when admin has selected "All branches" or no branch is set.

@ProviderFor(currentBranchId)
final currentBranchIdProvider = CurrentBranchIdProvider._();

/// Convenience provider for current branch ID.
///
/// Returns `null` when admin has selected "All branches" or no branch is set.

final class CurrentBranchIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for current branch ID.
  ///
  /// Returns `null` when admin has selected "All branches" or no branch is set.
  CurrentBranchIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBranchIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBranchIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentBranchId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBranchIdHash() => r'dd457fa7bdc31f57c2153247e3976e7a0f88db10';

/// Convenience provider for branch filter string.
///
/// Returns `branch = "id" && isDeleted = false` for a concrete branch,
/// `isDeleted = false` when viewing All branches, or null while unset/loading.

@ProviderFor(currentBranchFilter)
final currentBranchFilterProvider = CurrentBranchFilterProvider._();

/// Convenience provider for branch filter string.
///
/// Returns `branch = "id" && isDeleted = false` for a concrete branch,
/// `isDeleted = false` when viewing All branches, or null while unset/loading.

final class CurrentBranchFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for branch filter string.
  ///
  /// Returns `branch = "id" && isDeleted = false` for a concrete branch,
  /// `isDeleted = false` when viewing All branches, or null while unset/loading.
  CurrentBranchFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBranchFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBranchFilterHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentBranchFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBranchFilterHash() =>
    r'f0afd8e12d2e8114a3d20e70c42709f85999633d';

/// Branch ID to use when creating/updating records that require a branch.
///
/// Uses the current concrete branch when set. Returns null while "All" is
/// selected (writes must pick a specific branch). When no selection is set,
/// falls back to the authenticated user's default branch.

@ProviderFor(effectiveBranchIdForWrite)
final effectiveBranchIdForWriteProvider = EffectiveBranchIdForWriteProvider._();

/// Branch ID to use when creating/updating records that require a branch.
///
/// Uses the current concrete branch when set. Returns null while "All" is
/// selected (writes must pick a specific branch). When no selection is set,
/// falls back to the authenticated user's default branch.

final class EffectiveBranchIdForWriteProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Branch ID to use when creating/updating records that require a branch.
  ///
  /// Uses the current concrete branch when set. Returns null while "All" is
  /// selected (writes must pick a specific branch). When no selection is set,
  /// falls back to the authenticated user's default branch.
  EffectiveBranchIdForWriteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveBranchIdForWriteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveBranchIdForWriteHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return effectiveBranchIdForWrite(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$effectiveBranchIdForWriteHash() =>
    r'fd1808e4ce13be56b6171419db4c4f4e35b5cbdd';
