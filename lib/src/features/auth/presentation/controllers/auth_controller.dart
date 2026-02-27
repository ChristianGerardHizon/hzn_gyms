import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/routing/pending_redirect_provider.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';

part 'auth_controller.g.dart';

/// Controller for managing authentication state.
///
/// Provides methods for login, logout, and session management.
/// The state is [AuthState?] where null means not authenticated.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthState?> build() async {
    // Load cached auth immediately (no network call)
    final cachedResult = await _repository.getCachedAuth();

    return cachedResult.fold(
      (failure) => null, // No cached auth, return null (will redirect to login)
      (cachedAuth) {
        // Refresh token in background to validate and update
        _refreshInBackground();
        return cachedAuth;
      },
    );
  }

  /// Refreshes auth in the background. If refresh fails with auth error,
  /// logs the user out.
  Future<void> _refreshInBackground() async {
    final result = await _repository.refreshInBackground();

    result.fold(
      (failure) {
        // If token is invalid (401/403), log out
        if (failure is AuthFailure || failure is NoAuthFailure) {
          state = const AsyncData(null);
        }
        // For network errors, keep cached auth (user can work offline-ish)
      },
      (freshAuth) {
        // Update with fresh data silently
        state = AsyncData(freshAuth);
      },
    );
  }

  /// Attempts to login with username and password.
  ///
  /// Returns true on success, false on failure.
  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();

    final result = await _repository.login(username, password);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) {
        state = AsyncData(authState);
        return true;
      },
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    // Clear pending redirect to prevent unexpected navigation on next login
    ref.read(pendingRedirectProvider.notifier).consume();
    await _repository.logout();
    state = const AsyncData(null);
  }

  /// Refreshes the current authentication token.
  ///
  /// Returns true on success, false on failure.
  Future<bool> refresh() async {
    final result = await _repository.refresh();

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (authState) {
        state = AsyncData(authState);
        return true;
      },
    );
  }

  /// Requests a password reset email.
  Future<bool> requestPasswordReset(String email) async {
    final result = await _repository.requestPasswordReset(email);
    return result.isRight();
  }

}

/// Convenience provider to check if user is authenticated.
@Riverpod(keepAlive: true)
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.value != null;
}

/// Convenience provider to get the current user.
@Riverpod(keepAlive: true)
AuthState? currentAuth(Ref ref) {
  return ref.watch(authControllerProvider).value;
}
