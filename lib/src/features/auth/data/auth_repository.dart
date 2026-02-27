import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/foundation/failure.dart';
import '../../../core/foundation/type_defs.dart';
import '../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../core/packages/storage/auth_storage_provider.dart';
import '../domain/auth_state.dart';
import 'auth_dto.dart';

part 'auth_repository.g.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Attempts to login with username and password.
  FutureEither<AuthState> login(String username, String password);

  /// Logs out the current user.
  FutureEither<void> logout();

  /// Refreshes the current authentication token.
  FutureEither<AuthState> refresh();

  /// Initializes auth state from storage on app startup.
  FutureEither<AuthState> initialize();

  /// Returns cached auth from storage without network validation.
  FutureEither<AuthState> getCachedAuth();

  /// Refreshes auth token in the background using the current authStore.
  FutureEither<AuthState> refreshInBackground();

  /// Requests a password reset email.
  FutureEither<void> requestPasswordReset(String email);
}

/// Provides the auth repository instance.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    pb: ref.watch(pocketbaseProvider),
    authStorage: ref.read(authStorageProvider),
  );
}

/// Implementation of [AuthRepository] using PocketBase.
class AuthRepositoryImpl implements AuthRepository {
  final PocketBase pb;
  final AuthStorageService authStorage;

  AuthRepositoryImpl({
    required this.pb,
    required this.authStorage,
  });

  RecordService get _collection => pb.collection(PocketBaseCollections.users);
  String get _expand => 'branch';

  /// Creates an AuthState from an AuthDto.
  AuthState _createAuthState(AuthDto dto) {
    final user = dto.toUser(domain: pb.baseURL);
    return AuthState(token: dto.token, user: user);
  }

  @override
  FutureEither<AuthState> login(String username, String password) async {
    return TaskEither.tryCatch(
      () async {
        final result = await _collection.authWithPassword(
          username,
          password,
          expand: _expand,
        );

        final authDto = AuthDto.fromAuthResult(result);
        await authStorage.save(authDto);
        pb.authStore.save(authDto.token, authDto.toRecordModel());
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> logout() async {
    return TaskEither.tryCatch(
      () async {
        pb.authStore.clear();
        await authStorage.clear();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> refresh() async {
    return TaskEither.tryCatch(
      () async {
        final result = await _collection.authRefresh(expand: _expand);

        final authDto = AuthDto.fromAuthResult(result);
        await authStorage.save(authDto);
        pb.authStore.save(authDto.token, authDto.toRecordModel());
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> initialize() async {
    return TaskEither.tryCatch(
      () async {
        // Try to load saved auth data
        final savedAuth = await authStorage.get();
        if (savedAuth == null) {
          throw const NoAuthFailure('No saved authentication', null, 'no_auth');
        }

        // Restore token to PocketBase authStore
        pb.authStore.save(savedAuth.token, savedAuth.toRecordModel());

        // Refresh to validate token and get latest user data
        final result = await _collection.authRefresh(expand: _expand);

        final authDto = AuthDto.fromAuthResult(result);
        await authStorage.save(authDto);
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> getCachedAuth() async {
    return TaskEither.tryCatch(
      () async {
        final savedAuth = await authStorage.get();
        if (savedAuth == null) {
          throw const NoAuthFailure('No saved authentication', null, 'no_auth');
        }

        // Restore token to PocketBase authStore so API calls work
        pb.authStore.save(savedAuth.token, savedAuth.toRecordModel());

        return _createAuthState(savedAuth);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<AuthState> refreshInBackground() async {
    return TaskEither.tryCatch(
      () async {
        final result = await _collection.authRefresh(expand: _expand);

        final authDto = AuthDto.fromAuthResult(result);
        await authStorage.save(authDto);
        pb.authStore.save(authDto.token, authDto.toRecordModel());
        return _createAuthState(authDto);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> requestPasswordReset(String email) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.requestPasswordReset(email);
      },
      Failure.handle,
    ).run();
  }

}
