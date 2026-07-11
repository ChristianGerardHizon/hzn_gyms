// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing branch list state.
///
/// Provides methods for fetching and CRUD operations on branches.

@ProviderFor(BranchesController)
final branchesControllerProvider = BranchesControllerProvider._();

/// Controller for managing branch list state.
///
/// Provides methods for fetching and CRUD operations on branches.
final class BranchesControllerProvider
    extends $AsyncNotifierProvider<BranchesController, List<Branch>> {
  /// Controller for managing branch list state.
  ///
  /// Provides methods for fetching and CRUD operations on branches.
  BranchesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchesControllerHash();

  @$internal
  @override
  BranchesController create() => BranchesController();
}

String _$branchesControllerHash() =>
    r'9fd58c2e672509ee72627ad2cc977d4610b35669';

/// Controller for managing branch list state.
///
/// Provides methods for fetching and CRUD operations on branches.

abstract class _$BranchesController extends $AsyncNotifier<List<Branch>> {
  FutureOr<List<Branch>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Branch>>, List<Branch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Branch>>, List<Branch>>,
              AsyncValue<List<Branch>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
