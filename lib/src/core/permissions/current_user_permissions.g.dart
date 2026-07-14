// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the current user's role permissions from PocketBase.

@ProviderFor(currentUserPermissions)
final currentUserPermissionsProvider = CurrentUserPermissionsProvider._();

/// Loads the current user's role permissions from PocketBase.

final class CurrentUserPermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CurrentUserPermissions>,
          CurrentUserPermissions,
          FutureOr<CurrentUserPermissions>
        >
    with
        $FutureModifier<CurrentUserPermissions>,
        $FutureProvider<CurrentUserPermissions> {
  /// Loads the current user's role permissions from PocketBase.
  CurrentUserPermissionsProvider._()
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
  String debugGetCreateSourceHash() => _$currentUserPermissionsHash();

  @$internal
  @override
  $FutureProviderElement<CurrentUserPermissions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CurrentUserPermissions> create(Ref ref) {
    return currentUserPermissions(ref);
  }
}

String _$currentUserPermissionsHash() =>
    r'0b954497c6a88e78ff462acdeac9a000e2a6d904';
