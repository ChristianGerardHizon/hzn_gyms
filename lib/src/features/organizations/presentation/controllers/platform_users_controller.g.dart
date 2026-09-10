// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_users_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cross-org users list for platform operators (`/platform/users`).
///
/// Unlike [PaginatedUsersController], this does **not** filter by current org.

@ProviderFor(PlatformUsersController)
final platformUsersControllerProvider = PlatformUsersControllerProvider._();

/// Cross-org users list for platform operators (`/platform/users`).
///
/// Unlike [PaginatedUsersController], this does **not** filter by current org.
final class PlatformUsersControllerProvider
    extends
        $AsyncNotifierProvider<PlatformUsersController, PaginatedState<User>> {
  /// Cross-org users list for platform operators (`/platform/users`).
  ///
  /// Unlike [PaginatedUsersController], this does **not** filter by current org.
  PlatformUsersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformUsersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformUsersControllerHash();

  @$internal
  @override
  PlatformUsersController create() => PlatformUsersController();
}

String _$platformUsersControllerHash() =>
    r'0508ad0d27d77b0990f08105eb2df6b00f4be0b6';

/// Cross-org users list for platform operators (`/platform/users`).
///
/// Unlike [PaginatedUsersController], this does **not** filter by current org.

abstract class _$PlatformUsersController
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
