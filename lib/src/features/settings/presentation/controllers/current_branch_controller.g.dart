// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_branch_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches, persists selection
/// - For regular users: Locked to their assigned branch

@ProviderFor(CurrentBranchController)
final currentBranchControllerProvider = CurrentBranchControllerProvider._();

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches, persists selection
/// - For regular users: Locked to their assigned branch
final class CurrentBranchControllerProvider
    extends $AsyncNotifierProvider<CurrentBranchController, Branch?> {
  /// Controller for managing the current working branch.
  ///
  /// - For admins: Allows switching between branches, persists selection
  /// - For regular users: Locked to their assigned branch
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
    r'93cc2977b0672215c7dfbb55dd3d3d7c180dfa52';

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches, persists selection
/// - For regular users: Locked to their assigned branch

abstract class _$CurrentBranchController extends $AsyncNotifier<Branch?> {
  FutureOr<Branch?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Branch?>, Branch?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Branch?>, Branch?>,
        AsyncValue<Branch?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Convenience provider for current branch ID.

@ProviderFor(currentBranchId)
final currentBranchIdProvider = CurrentBranchIdProvider._();

/// Convenience provider for current branch ID.

final class CurrentBranchIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for current branch ID.
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
/// Returns a filter string like `branch = "id"` or null if no branch selected.

@ProviderFor(currentBranchFilter)
final currentBranchFilterProvider = CurrentBranchFilterProvider._();

/// Convenience provider for branch filter string.
///
/// Returns a filter string like `branch = "id"` or null if no branch selected.

final class CurrentBranchFilterProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for branch filter string.
  ///
  /// Returns a filter string like `branch = "id"` or null if no branch selected.
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
    r'ff9f628f86fd25ae80daf902e8b4a25457a0c5ba';
