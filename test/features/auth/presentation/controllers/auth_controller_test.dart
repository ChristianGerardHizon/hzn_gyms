import 'dart:async';

import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/features/auth/data/auth_repository.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _cachedAuth = AuthState(
  token: 'old-tok',
  user: User(id: 'u1', name: 'Old User', email: 'cashier@test.com', verified: true),
);

const _newAuth = AuthState(
  token: 'new-tok',
  user: User(id: 'u1', name: 'New User', email: 'cashier@test.com', verified: true),
);

void main() {
  late MockAuthRepository repo;
  Completer<Either<Failure, AuthState>>? refreshCompleter;

  setUp(() {
    repo = MockAuthRepository();
    refreshCompleter = Completer<Either<Failure, AuthState>>();

    when(() => repo.getCachedAuth()).thenAnswer((_) async => right(_cachedAuth));
    when(() => repo.refreshInBackground()).thenAnswer(
      (_) => refreshCompleter!.future,
    );
    when(() => repo.logout()).thenAnswer((_) async => right(null));
    when(() => repo.login(any(), any())).thenAnswer(
      (_) async => right(_newAuth),
    );
  });

  group('AuthController', () {
    test(
      'ignores stale background refresh after logout and re-login',
      () async {
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.future);
        expect(container.read(authControllerProvider).value, _cachedAuth);

        await container.read(authControllerProvider.notifier).logout();
        expect(container.read(authControllerProvider).value, isNull);

        final loginOk = await container
            .read(authControllerProvider.notifier)
            .login('cashier', 'secret');
        expect(loginOk, isTrue);
        expect(container.read(authControllerProvider).value, _newAuth);

        refreshCompleter!.complete(
          left(const AuthFailure('Token expired', null, 'auth')),
        );
        await Future<void>.delayed(Duration.zero);

        expect(container.read(authControllerProvider).value, _newAuth);
      },
    );

    test(
      'ignores stale background refresh success after logout and re-login',
      () async {
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.future);
        await container.read(authControllerProvider.notifier).logout();
        await container
            .read(authControllerProvider.notifier)
            .login('cashier', 'secret');

        refreshCompleter!.complete(right(_cachedAuth));
        await Future<void>.delayed(Duration.zero);

        expect(container.read(authControllerProvider).value, _newAuth);
      },
    );
  });
}
