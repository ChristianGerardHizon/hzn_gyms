import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_gyms/src/core/foundation/type_defs.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/users/data/repositories/user_repository.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/paginated_users_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository userRepo;

  const org = Organization(id: 'org-1', name: 'Kylie Gym', slug: 'kyliegym');
  const user = User(id: 'user-1', name: 'Admin', email: 'admin@example.com');

  setUp(() {
    userRepo = MockUserRepository();
    when(
      () => userRepo.fetchPaginated(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer(
      (_) async => right(
        const PaginatedResult<User>(
          items: [user],
          page: 1,
          totalItems: 1,
          totalPages: 1,
        ),
      ),
    );
  });

  test('build applies organization filter when current org is set', () async {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(userRepo),
        currentOrganizationControllerProvider.overrideWith(
          () => _FixedCurrentOrganization(org),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(currentOrganizationControllerProvider.future);
    final state = await container.read(paginatedUsersControllerProvider.future);

    expect(state.items, [user]);
    final capturedFilter = verify(
      () => userRepo.fetchPaginated(
        page: 1,
        perPage: any(named: 'perPage'),
        filter: captureAny(named: 'filter'),
      ),
    ).captured.single as String;
    expect(capturedFilter, contains('organization = "org-1"'));
  });
}

class _FixedCurrentOrganization extends CurrentOrganizationController {
  _FixedCurrentOrganization(this._org);

  final Organization _org;

  @override
  Future<Organization?> build() async => _org;
}
