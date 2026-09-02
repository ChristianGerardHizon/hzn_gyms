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
    r'4b416f991a5ab6f3e20bb1ed3468de17c6530d51';

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

/// Whether the signed-in user may use the organization switcher.
///
/// Platform super-admins need [Permissions.organizationsManage] and must not
/// be linked to a tenant on their user record (org-scoped staff stay on their
/// tenant even if their role incorrectly includes organizations.manage).

@ProviderFor(canUseOrganizationSwitcher)
final canUseOrganizationSwitcherProvider =
    CanUseOrganizationSwitcherProvider._();

/// Whether the signed-in user may use the organization switcher.
///
/// Platform super-admins need [Permissions.organizationsManage] and must not
/// be linked to a tenant on their user record (org-scoped staff stay on their
/// tenant even if their role incorrectly includes organizations.manage).

final class CanUseOrganizationSwitcherProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in user may use the organization switcher.
  ///
  /// Platform super-admins need [Permissions.organizationsManage] and must not
  /// be linked to a tenant on their user record (org-scoped staff stay on their
  /// tenant even if their role incorrectly includes organizations.manage).
  CanUseOrganizationSwitcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canUseOrganizationSwitcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canUseOrganizationSwitcherHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canUseOrganizationSwitcher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canUseOrganizationSwitcherHash() =>
    r'dbda7ceef60df99fdd0bb9f89a138c0a79ef1a20';
