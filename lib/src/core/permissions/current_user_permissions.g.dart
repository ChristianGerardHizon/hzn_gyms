// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and silently refreshes the current user's role permissions.
///
/// Keeps the last known permissions visible while re-fetching in the
/// background (realtime role updates + periodic poll).

@ProviderFor(CurrentUserPermissionsController)
final currentUserPermissionsProvider =
    CurrentUserPermissionsControllerProvider._();

/// Loads and silently refreshes the current user's role permissions.
///
/// Keeps the last known permissions visible while re-fetching in the
/// background (realtime role updates + periodic poll).
final class CurrentUserPermissionsControllerProvider
    extends
        $AsyncNotifierProvider<
          CurrentUserPermissionsController,
          CurrentUserPermissions
        > {
  /// Loads and silently refreshes the current user's role permissions.
  ///
  /// Keeps the last known permissions visible while re-fetching in the
  /// background (realtime role updates + periodic poll).
  CurrentUserPermissionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserPermissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserPermissionsControllerHash();

  @$internal
  @override
  CurrentUserPermissionsController create() =>
      CurrentUserPermissionsController();
}

String _$currentUserPermissionsControllerHash() =>
    r'789a2a1796826f037de746047418fb53bb247b81';

/// Loads and silently refreshes the current user's role permissions.
///
/// Keeps the last known permissions visible while re-fetching in the
/// background (realtime role updates + periodic poll).

abstract class _$CurrentUserPermissionsController
    extends $AsyncNotifier<CurrentUserPermissions> {
  FutureOr<CurrentUserPermissions> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CurrentUserPermissions>, CurrentUserPermissions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CurrentUserPermissions>,
                CurrentUserPermissions
              >,
              AsyncValue<CurrentUserPermissions>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
