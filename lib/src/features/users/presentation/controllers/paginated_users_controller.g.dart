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
    r'1766ba4f5165a62939c4192011219a89d52ced7d';

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
