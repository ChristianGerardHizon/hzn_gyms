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

  /// Invalidates in-flight [_refreshInBackground] calls after login/logout.
  int _refreshGeneration = 0;

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
    final generation = _refreshGeneration;
    final result = await _repository.refreshInBackground();

    if (generation != _refreshGeneration) return;

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

  void _invalidateBackgroundRefresh() {
    _refreshGeneration++;
  }

  /// Attempts to login with email and password.
  ///
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    _invalidateBackgroundRefresh();
    state = const AsyncLoading();

    final result = await _repository.login(email, password);

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

  /// Attempts Google OAuth2 login (web).
  ///
  /// Does not set [AsyncLoading] while waiting: PocketBase OAuth waits on a
  /// realtime redirect that never completes if the user closes the popup/tab,
  /// which would permanently disable the login form.
  ///
  /// Returns true on success, false on failure.
  Future<bool> loginWithGoogle() async {
    _invalidateBackgroundRefresh();

    final result = await _repository.loginWithGoogle();

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
    _invalidateBackgroundRefresh();
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

  /// Requests a verification email for the signed-in user's address.
  Future<bool> requestVerification(String email) async {
    final result = await _repository.requestVerification(email);
    return result.isRight();
  }

  /// Confirms email verification with [token], then refreshes the session.
  ///
  /// Returns true when confirmation and refresh both succeed and the user
  /// is verified.
  Future<bool> confirmVerification(String token) async {
    final confirmResult = await _repository.confirmVerification(token);
    final confirmed = confirmResult.fold((_) => false, (_) => true);
    if (!confirmed) return false;

    final refreshed = await refresh();
    if (!refreshed) return false;
    return state.value?.isVerified ?? false;
  }

  /// Requests an email OTP. Does not change global auth loading state.
  ///
  /// Returns the OTP id on success, or null on failure.
  Future<String?> requestOtp(String email) async {
    final result = await _repository.requestOtp(email);
    return result.fold((_) => null, (otpId) => otpId);
  }

  /// Logs in with an email OTP id and code.
  ///
  /// Returns true on success, false on failure.
  Future<bool> loginWithOtp(String otpId, String code) async {
    _invalidateBackgroundRefresh();
    state = const AsyncLoading();

    final result = await _repository.loginWithOtp(otpId, code);

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
