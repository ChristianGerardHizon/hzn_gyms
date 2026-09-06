import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_gyms/src/features/organizations/data/repositories/organization_repository.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_dns_status.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_setup_status.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organization_setup_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/users/data/repositories/user_repository.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizationRepository extends Mock
    implements OrganizationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockOrganizationRepository orgRepo;
  late MockUserRepository userRepo;

  const orgId = 'org-1';
  const org = Organization(
    id: orgId,
    name: 'Kylie Gym',
    slug: 'kyliegym',
    dnsStatus: OrganizationDnsStatus.created,
    setupStatus: OrganizationSetupStatus.pendingSetup,
  );
  const branch = Branch(
    id: 'branch-1',
    name: 'Main',
    code: 'MAIN',
    address: '',
    contactNumber: '',
    organization: orgId,
  );
  const admin = User(
    id: 'user-1',
    name: 'Admin',
    username: 'admin',
    email: 'admin@example.com',
    branchId: 'branch-1',
    roleName: 'Admin',
    organizationId: orgId,
  );

  setUp(() {
    orgRepo = MockOrganizationRepository();
    userRepo = MockUserRepository();

    when(() => orgRepo.fetchOne(orgId)).thenAnswer((_) async => right(org));
    when(
      () => userRepo.fetchAll(filter: 'organization = "$orgId"'),
    ).thenAnswer((_) async => right([admin]));
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        organizationRepositoryProvider.overrideWithValue(orgRepo),
        userRepositoryProvider.overrideWithValue(userRepo),
        branchesControllerProvider.overrideWith(
          () => _FixedBranches([branch]),
        ),
        currentOrganizationControllerProvider.overrideWith(
          () => _NoopCurrentOrganization(),
        ),
        organizationsControllerProvider.overrideWith(
          () => _EmptyOrganizations(),
        ),
      ],
    );
  }

  test('build detects branch and admin user progress', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final state = await container.read(
      organizationSetupControllerProvider(orgId).future,
    );

    expect(state.hasBranch, isTrue);
    expect(state.hasAdminUser, isTrue);
    expect(state.adminUserEmail, 'admin@example.com');
    expect(state.canComplete, isTrue);
  });

  test('completeSetup calls repository and updates organization', () async {
    const readyOrg = Organization(
      id: orgId,
      name: 'Kylie Gym',
      slug: 'kyliegym',
      dnsStatus: OrganizationDnsStatus.created,
      setupStatus: OrganizationSetupStatus.ready,
    );
    when(() => orgRepo.completeSetup(orgId))
        .thenAnswer((_) async => right(readyOrg));

    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(organizationSetupControllerProvider(orgId).future);
    final notifier = container.read(
      organizationSetupControllerProvider(orgId).notifier,
    );

    final success = await notifier.completeSetup();
    expect(success, isTrue);

    final updated = container.read(organizationSetupControllerProvider(orgId));
    expect(updated.value?.organization.setupStatus.isReady, isTrue);
  });

  test('markMembershipSkipped updates optional step flags', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(organizationSetupControllerProvider(orgId).future);
    final notifier = container.read(
      organizationSetupControllerProvider(orgId).notifier,
    );

    notifier.markMembershipSkipped();

    final updated = container.read(organizationSetupControllerProvider(orgId));
    expect(updated.value?.skippedMembership, isTrue);
  });
}

class _FixedBranches extends BranchesController {
  _FixedBranches(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

class _NoopCurrentOrganization extends CurrentOrganizationController {
  @override
  Future<Organization?> build() async => null;

  @override
  Future<void> switchOrganization(String organizationId) async {}
}

class _EmptyOrganizations extends OrganizationsController {
  @override
  Future<List<Organization>> build() async => [];
}
