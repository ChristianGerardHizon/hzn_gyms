import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/packages/storage/secure_storage_provider.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/organizations/data/repositories/organization_repository.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/tenant_scope_invalidation.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizationRepository extends Mock
    implements OrganizationRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockOrganizationRepository orgRepo;
  late MockFlutterSecureStorage storage;

  const org = Organization(
    id: 'org-1',
    name: 'Kylie Gym',
    slug: 'kyliegym',
  );

  const authWithOrg = AuthState(
    token: 'tok',
    user: User(
      id: 'u1',
      name: 'Staff',
      email: 'staff@test.com',
      verified: true,
      organization: 'org-1',
    ),
  );

  setUp(() {
    orgRepo = MockOrganizationRepository();
    storage = MockFlutterSecureStorage();

    when(
      () => storage.read(key: 'CURRENT_ORGANIZATION_ID'),
    ).thenAnswer((_) async => null);
    when(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((_) async {});
  });

  ProviderContainer createContainer({AuthState? auth}) {
    return ProviderContainer(
      overrides: [
        organizationRepositoryProvider.overrideWithValue(orgRepo),
        secureStorageProvider.overrideWithValue(storage),
        currentAuthProvider.overrideWithValue(auth),
      ],
    );
  }

  test('returns null when signed out', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final org = await container.read(currentOrganizationControllerProvider.future);

    expect(org, isNull);
    verifyNever(() => orgRepo.fetchOne(any()));
    verifyNever(() => orgRepo.fetchBySlugOrHostname(any()));
  });

  test('resolves organization from signed-in user after login', () async {
    when(() => orgRepo.fetchOne('org-1')).thenAnswer((_) async => right(org));

    final container = createContainer(auth: authWithOrg);
    addTearDown(container.dispose);

    final resolved =
        await container.read(currentOrganizationControllerProvider.future);

    expect(resolved, org);
    verify(() => orgRepo.fetchOne('org-1')).called(1);
    verifyNever(() => orgRepo.fetchBySlugOrHostname(any()));
  });

  test('falls back to persisted org when user has no organization field', () async {
    const superAdminAuth = AuthState(
      token: 'tok',
      user: User(
        id: 'admin',
        name: 'Admin',
        email: 'admin@test.com',
        verified: true,
      ),
    );

    when(
      () => storage.read(key: 'CURRENT_ORGANIZATION_ID'),
    ).thenAnswer((_) async => 'org-1');
    when(() => orgRepo.fetchOne('org-1')).thenAnswer((_) async => right(org));

    final container = createContainer(auth: superAdminAuth);
    addTearDown(container.dispose);

    final resolved =
        await container.read(currentOrganizationControllerProvider.future);

    expect(resolved, org);
    verify(() => orgRepo.fetchOne('org-1')).called(1);
  });

  test('user organization wins over persisted choice', () async {
    when(
      () => storage.read(key: 'CURRENT_ORGANIZATION_ID'),
    ).thenAnswer((_) async => 'org-other');
    when(() => orgRepo.fetchOne('org-1')).thenAnswer((_) async => right(org));

    final container = createContainer(auth: authWithOrg);
    addTearDown(container.dispose);

    final resolved =
        await container.read(currentOrganizationControllerProvider.future);

    expect(resolved, org);
    verify(() => orgRepo.fetchOne('org-1')).called(1);
    verifyNever(() => orgRepo.fetchOne('org-other'));
  });

  test('currentOrganizationId falls back to auth when org fetch fails', () async {
    when(() => orgRepo.fetchOne('org-1')).thenAnswer(
      (_) async => left(const DataFailure('not found', null, 'not_found')),
    );

    final container = createContainer(auth: authWithOrg);
    addTearDown(container.dispose);

    await container.read(currentOrganizationControllerProvider.future);

    expect(container.read(currentOrganizationControllerProvider).value, isNull);
    expect(container.read(currentOrganizationIdProvider), 'org-1');
  });

  test(
    'invalidateTenantScopedProviders from org notifier does not circular-depend',
    () async {
      when(() => orgRepo.fetchOne('org-1')).thenAnswer((_) async => right(org));

      final container = createContainer(auth: authWithOrg);
      addTearDown(container.dispose);

      await container.read(currentOrganizationControllerProvider.future);
      // Establish orgId → orgController edge (same graph branch controllers use).
      expect(container.read(currentOrganizationIdProvider), 'org-1');

      final notifier =
          container.read(currentOrganizationControllerProvider.notifier);

      // Must use container.invalidate — ref.invalidate of org-dependent
      // providers from this notifier throws CircularDependencyError.
      expect(
        () => invalidateTenantScopedProviders(notifier.ref.container),
        returnsNormally,
      );
    },
  );
}
