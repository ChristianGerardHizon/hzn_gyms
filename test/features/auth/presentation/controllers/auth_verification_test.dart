import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/features/auth/data/auth_repository.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/auth/presentation/pages/verify_email_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _unverified = AuthState(
  token: 'tok',
  user: User(
    id: 'u1',
    name: 'User',
    email: 'user@test.com',
    verified: false,
  ),
);

const _verified = AuthState(
  token: 'tok',
  user: User(
    id: 'u1',
    name: 'User',
    email: 'user@test.com',
    verified: true,
  ),
);

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.getCachedAuth()).thenAnswer((_) async => right(_unverified));
    when(() => repo.refreshInBackground()).thenAnswer(
      (_) async => right(_unverified),
    );
  });

  test('requestVerification delegates to repository', () async {
    when(() => repo.requestVerification(any())).thenAnswer(
      (_) async => right(null),
    );

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final ok = await container
        .read(authControllerProvider.notifier)
        .requestVerification('user@test.com');

    expect(ok, isTrue);
    verify(() => repo.requestVerification('user@test.com')).called(1);
  });

  test('confirmVerification refreshes and reports verified', () async {
    when(() => repo.confirmVerification(any())).thenAnswer(
      (_) async => right(null),
    );
    when(() => repo.refresh()).thenAnswer((_) async => right(_verified));

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final ok = await container
        .read(authControllerProvider.notifier)
        .confirmVerification('token-abc');

    expect(ok, isTrue);
    expect(container.read(authControllerProvider).value?.isVerified, isTrue);
    verify(() => repo.confirmVerification('token-abc')).called(1);
    verify(() => repo.refresh()).called(1);
  });

  test('confirmVerification returns false when confirm fails', () async {
    when(() => repo.confirmVerification(any())).thenAnswer(
      (_) async => left(const AuthFailure('bad token', null, 'auth')),
    );

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final ok = await container
        .read(authControllerProvider.notifier)
        .confirmVerification('bad');

    expect(ok, isFalse);
    verifyNever(() => repo.refresh());
  });

  test('verification resend cooldown is 60 seconds', () {
    expect(kVerificationResendCooldown, const Duration(seconds: 60));
  });
}
