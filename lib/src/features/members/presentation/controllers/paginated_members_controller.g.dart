// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing paginated members list.
///
/// By default the list is branch-agnostic (not tied to the global branch
/// switcher). An optional [memberActiveBranchFilterProvider] limits results to
/// members with a currently active membership valid at the selected branch.

@ProviderFor(PaginatedMembersController)
final paginatedMembersControllerProvider =
    PaginatedMembersControllerProvider._();

/// Controller for managing paginated members list.
///
/// By default the list is branch-agnostic (not tied to the global branch
/// switcher). An optional [memberActiveBranchFilterProvider] limits results to
/// members with a currently active membership valid at the selected branch.
final class PaginatedMembersControllerProvider
    extends
        $AsyncNotifierProvider<
          PaginatedMembersController,
          PaginatedState<Member>
        > {
  /// Controller for managing paginated members list.
  ///
  /// By default the list is branch-agnostic (not tied to the global branch
  /// switcher). An optional [memberActiveBranchFilterProvider] limits results to
  /// members with a currently active membership valid at the selected branch.
  PaginatedMembersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedMembersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedMembersControllerHash();

  @$internal
  @override
  PaginatedMembersController create() => PaginatedMembersController();
}

String _$paginatedMembersControllerHash() =>
    r'3c8888bc62c4a9e9051b756c750f6e2b8c579dcd';

/// Controller for managing paginated members list.
///
/// By default the list is branch-agnostic (not tied to the global branch
/// switcher). An optional [memberActiveBranchFilterProvider] limits results to
/// members with a currently active membership valid at the selected branch.

abstract class _$PaginatedMembersController
    extends $AsyncNotifier<PaginatedState<Member>> {
  FutureOr<PaginatedState<Member>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedState<Member>>, PaginatedState<Member>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<Member>>,
                PaginatedState<Member>
              >,
              AsyncValue<PaginatedState<Member>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
