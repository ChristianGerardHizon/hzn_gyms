// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing paginated members list.
///
/// Members are branch-agnostic — lists and search are not filtered by the
/// current branch switcher.

@ProviderFor(PaginatedMembersController)
final paginatedMembersControllerProvider =
    PaginatedMembersControllerProvider._();

/// Controller for managing paginated members list.
///
/// Members are branch-agnostic — lists and search are not filtered by the
/// current branch switcher.
final class PaginatedMembersControllerProvider
    extends
        $AsyncNotifierProvider<
          PaginatedMembersController,
          PaginatedState<Member>
        > {
  /// Controller for managing paginated members list.
  ///
  /// Members are branch-agnostic — lists and search are not filtered by the
  /// current branch switcher.
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
    r'181041de21693de4fd4672d96089a3610fd29e45';

/// Controller for managing paginated members list.
///
/// Members are branch-agnostic — lists and search are not filtered by the
/// current branch switcher.

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
