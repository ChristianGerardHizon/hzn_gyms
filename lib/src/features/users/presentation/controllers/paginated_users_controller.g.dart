// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_users_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing paginated users list.

@ProviderFor(PaginatedUsersController)
final paginatedUsersControllerProvider = PaginatedUsersControllerProvider._();

/// Controller for managing paginated users list.
final class PaginatedUsersControllerProvider
    extends
        $AsyncNotifierProvider<PaginatedUsersController, PaginatedState<User>> {
  /// Controller for managing paginated users list.
  PaginatedUsersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedUsersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedUsersControllerHash();

  @$internal
  @override
  PaginatedUsersController create() => PaginatedUsersController();
}

String _$paginatedUsersControllerHash() =>
    r'7af2ed27d7032518377887ba41c0a04d5454a5a3';

/// Controller for managing paginated users list.

abstract class _$PaginatedUsersController
    extends $AsyncNotifier<PaginatedState<User>> {
  FutureOr<PaginatedState<User>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedState<User>>, PaginatedState<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<User>>,
                PaginatedState<User>
              >,
              AsyncValue<PaginatedState<User>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
