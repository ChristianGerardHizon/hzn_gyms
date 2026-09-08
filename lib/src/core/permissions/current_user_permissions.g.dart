// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and silently refreshes the current user's role permissions.
///
/// Prefer the active organization's membership role when present so the same
/// user can hold different roles per tenant. Platform [superAdmin] always
/// comes from the user record. KeepAlive poll/realtime still refresh the
/// resolved role permissions.

@ProviderFor(CurrentUserPermissionsController)
final currentUserPermissionsProvider =
    CurrentUserPermissionsControllerProvider._();

/// Loads and silently refreshes the current user's role permissions.
///
/// Prefer the active organization's membership role when present so the same
/// user can hold different roles per tenant. Platform [superAdmin] always
/// comes from the user record. KeepAlive poll/realtime still refresh the
/// resolved role permissions.
final class CurrentUserPermissionsControllerProvider
    extends
        $AsyncNotifierProvider<
          CurrentUserPermissionsController,
          CurrentUserPermissions
        > {
  /// Loads and silently refreshes the current user's role permissions.
  ///
  /// Prefer the active organization's membership role when present so the same
  /// user can hold different roles per tenant. Platform [superAdmin] always
  /// comes from the user record. KeepAlive poll/realtime still refresh the
  /// resolved role permissions.
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
    r'81a1490362aa8c8ec68c5f8d9d6411325b6e16f8';

/// Loads and silently refreshes the current user's role permissions.
///
/// Prefer the active organization's membership role when present so the same
/// user can hold different roles per tenant. Platform [superAdmin] always
/// comes from the user record. KeepAlive poll/realtime still refresh the
/// resolved role permissions.

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
/// Platform operators (`users.superAdmin`) can switch tenants even when
/// `users.organization` is set (active tenant for PB rules / gym data).

@ProviderFor(canUseOrganizationSwitcher)
final canUseOrganizationSwitcherProvider =
    CanUseOrganizationSwitcherProvider._();

/// Whether the signed-in user may use the organization switcher.
///
/// Platform operators (`users.superAdmin`) can switch tenants even when
/// `users.organization` is set (active tenant for PB rules / gym data).

final class CanUseOrganizationSwitcherProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in user may use the organization switcher.
  ///
  /// Platform operators (`users.superAdmin`) can switch tenants even when
  /// `users.organization` is set (active tenant for PB rules / gym data).
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
    r'c542ce0e42b76f0c86a7fe03552b361c1ac3de72';
