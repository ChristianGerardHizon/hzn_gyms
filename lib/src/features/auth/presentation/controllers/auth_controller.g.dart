// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing authentication state.
///
/// Provides methods for login, logout, and session management.
/// The state is [AuthState?] where null means not authenticated.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Controller for managing authentication state.
///
/// Provides methods for login, logout, and session management.
/// The state is [AuthState?] where null means not authenticated.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthState?> {
  /// Controller for managing authentication state.
  ///
  /// Provides methods for login, logout, and session management.
  /// The state is [AuthState?] where null means not authenticated.
  AuthControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'552abf4123ce4de2b1452c3d4aa9cdc775a05940';

/// Controller for managing authentication state.
///
/// Provides methods for login, logout, and session management.
/// The state is [AuthState?] where null means not authenticated.

abstract class _$AuthController extends $AsyncNotifier<AuthState?> {
  FutureOr<AuthState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState?>, AuthState?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthState?>, AuthState?>,
        AsyncValue<AuthState?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Convenience provider to check if user is authenticated.

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Convenience provider to check if user is authenticated.

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Convenience provider to check if user is authenticated.
  IsAuthenticatedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isAuthenticatedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'23917b6e20580eeb614889c080e0a0966f68e63f';

/// Convenience provider to get the current user.

@ProviderFor(currentAuth)
final currentAuthProvider = CurrentAuthProvider._();

/// Convenience provider to get the current user.

final class CurrentAuthProvider
    extends $FunctionalProvider<AuthState?, AuthState?, AuthState?>
    with $Provider<AuthState?> {
  /// Convenience provider to get the current user.
  CurrentAuthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentAuthProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentAuthHash();

  @$internal
  @override
  $ProviderElement<AuthState?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthState? create(Ref ref) {
    return currentAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState?>(value),
    );
  }
}

String _$currentAuthHash() => r'1b1aa3942eb6c6c013694b2b6e5d379fa49cef15';
