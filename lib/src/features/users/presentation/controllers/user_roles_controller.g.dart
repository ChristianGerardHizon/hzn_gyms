// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_roles_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing user roles list.

@ProviderFor(UserRolesController)
final userRolesControllerProvider = UserRolesControllerProvider._();

/// Controller for managing user roles list.
final class UserRolesControllerProvider
    extends $AsyncNotifierProvider<UserRolesController, List<UserRole>> {
  /// Controller for managing user roles list.
  UserRolesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRolesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRolesControllerHash();

  @$internal
  @override
  UserRolesController create() => UserRolesController();
}

String _$userRolesControllerHash() =>
    r'695f6ebfc5c2fa497dddcd52f30b1be35409adfb';

/// Controller for managing user roles list.

abstract class _$UserRolesController extends $AsyncNotifier<List<UserRole>> {
  FutureOr<List<UserRole>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<UserRole>>, List<UserRole>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserRole>>, List<UserRole>>,
              AsyncValue<List<UserRole>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
