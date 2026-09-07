import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/features/organizations/data/repositories/organization_repository.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizationRepository extends Mock
    implements OrganizationRepository {}

void main() {
  late MockOrganizationRepository repo;
  late ProviderContainer container;

  const orgA = Organization(
    id: 'org-a',
    name: 'Org A',
    slug: 'org-a',
  );
  const orgB = Organization(
    id: 'org-b',
    name: 'Org B',
    slug: 'org-b',
  );

  setUp(() {
    repo = MockOrganizationRepository();
    when(() => repo.fetchAll()).thenAnswer((_) async => right([orgA, orgB]));

    container = ProviderContainer(
      overrides: [
        organizationRepositoryProvider.overrideWithValue(repo),
      ],
    );
    container.listen(organizationsControllerProvider, (_, __) {});
  });

  tearDown(() {
    container.dispose();
  });

  test('build loads organizations from repository', () async {
    final list = await container.read(organizationsControllerProvider.future);
    expect(list, [orgA, orgB]);
  });

  test('createOrganization prepends new org to list', () async {
    const created = Organization(id: 'org-c', name: 'Org C', slug: 'org-c');
    when(() => repo.create(created)).thenAnswer((_) async => right(created));

    await container.read(organizationsControllerProvider.future);
    final controller =
        container.read(organizationsControllerProvider.notifier);

    final success = await controller.createOrganization(created);
    expect(success, created);
    expect(
      container.read(organizationsControllerProvider).value,
      [created, orgA, orgB],
    );
  });

  test('createOrganization returns null on failure', () async {
    const created = Organization(id: 'org-c', name: 'Org C', slug: 'org-c');
    when(() => repo.create(created)).thenAnswer(
      (_) async => left(const DataFailure('fail', null, 'create_failed')),
    );

    await container.read(organizationsControllerProvider.future);
    final controller =
        container.read(organizationsControllerProvider.notifier);

    final success = await controller.createOrganization(created);
    expect(success, isNull);
    expect(
      container.read(organizationsControllerProvider).value,
      [orgA, orgB],
    );
  });
}
