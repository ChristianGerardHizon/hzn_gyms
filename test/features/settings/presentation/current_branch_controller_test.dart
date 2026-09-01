import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pb_filter.dart';
import 'package:hzn_gyms/src/core/packages/storage/secure_storage_provider.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart' as users;
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_provider.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_role_provider.dart';

import '../../../helpers/fixtures.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

void main() {
  const branchA = Branch(
    id: 'branch-a',
    name: 'A',
    code: 'A',
    address: 'x',
    contactNumber: '1',
  );
  const branchB = Branch(
    id: 'branch-b',
    name: 'B',
    code: 'B',
    address: 'y',
    contactNumber: '2',
  );

  late MockFlutterSecureStorage storage;
  final Map<String, String> store = {};

  setUp(() {
    storage = MockFlutterSecureStorage();
    store.clear();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return store[key];
    });
    when(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String;
      store[key] = value;
    });
  });

  ProviderContainer createContainer({
    required bool admin,
    String? authBranch = 'branch-a',
    List<String> allowed = const ['branch-a', 'branch-b'],
    String? persisted,
  }) {
    if (persisted != null) {
      store['CURRENT_BRANCH_ID'] = persisted;
    }

    final auth = buildAuthState().copyWith(
      user: buildAuthState().user.copyWith(
            id: 'user-1',
            branch: authBranch,
            allowedBranches: allowed,
          ),
    );

    return ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        currentAuthProvider.overrideWithValue(auth),
        userProvider('user-1').overrideWith(
          (ref) async => users.User(
            id: 'user-1',
            name: 'Cashier',
            username: 'cashier',
            roleId: 'role-1',
            branchId: authBranch,
          ),
        ),
        userRoleProvider('role-1').overrideWith(
          (ref) async => UserRole(
            id: 'role-1',
            name: admin ? 'Admin' : 'Staff',
            permissions: admin ? [Permissions.systemAdmin] : const [],
          ),
        ),
        branchesControllerProvider.overrideWith(
          () => _FakeBranchesController([branchA, branchB]),
        ),
      ],
    );
  }

  test('no auth yields empty selection', () async {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        currentAuthProvider.overrideWithValue(null),
        branchesControllerProvider.overrideWith(
          () => _FakeBranchesController([branchA]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final selection =
        await container.read(currentBranchControllerProvider.future);
    expect(selection.branch, isNull);
    expect(selection.isAll, isFalse);
  });

  test('admin with persisted All branches', () async {
    final container = createContainer(
      admin: true,
      persisted: allBranchesSentinel,
    );
    addTearDown(container.dispose);

    final selection =
        await container.read(currentBranchControllerProvider.future);
    expect(selection.isAll, isTrue);
    expect(container.read(viewingAllBranchesProvider), isTrue);
    expect(container.read(currentBranchIdProvider), isNull);
    expect(container.read(effectiveBranchIdForWriteProvider), isNull);
    expect(
      container.read(currentBranchFilterProvider),
      PBFilters.active.build(),
    );
  });

  test('non-admin uses persisted allowed branch', () async {
    final container = createContainer(
      admin: false,
      persisted: 'branch-b',
    );
    addTearDown(container.dispose);

    final selection =
        await container.read(currentBranchControllerProvider.future);
    expect(selection.branch?.id, 'branch-b');
    expect(container.read(currentBranchIdProvider), 'branch-b');
    expect(container.read(effectiveBranchIdForWriteProvider), 'branch-b');
    expect(
      container.read(currentBranchFilterProvider),
      PBFilters.forBranch('branch-b').build(),
    );
  });

  test('canSwitchBranch and switchBranch rules', () async {
    final staff = createContainer(admin: false, allowed: ['branch-a']);
    addTearDown(staff.dispose);
    await staff.read(currentBranchControllerProvider.future);
    expect(
      await staff.read(currentBranchControllerProvider.notifier).canSwitchBranch(),
      isFalse,
    );

    final admin = createContainer(admin: true);
    addTearDown(admin.dispose);
    await admin.read(currentBranchControllerProvider.future);
    final notifier = admin.read(currentBranchControllerProvider.notifier);
    expect(await notifier.canSwitchBranch(), isTrue);
    expect(await notifier.canViewAllBranches(), isTrue);

    await notifier.switchBranch(allBranchesSentinel);
    expect(admin.read(currentBranchControllerProvider).value?.isAll, isTrue);
    expect(store['CURRENT_BRANCH_ID'], allBranchesSentinel);

    await notifier.switchBranch('branch-b');
    expect(admin.read(currentBranchControllerProvider).value?.branch?.id, 'branch-b');
  });

  test('switchBranch keeps previous selection while loading', () async {
    final admin = createContainer(admin: true, persisted: 'branch-a');
    addTearDown(admin.dispose);
    await admin.read(currentBranchControllerProvider.future);
    final notifier = admin.read(currentBranchControllerProvider.notifier);

    final emitted = <AsyncValue<CurrentBranchSelection>>[];
    final sub = admin.listen(
      currentBranchControllerProvider,
      (_, next) => emitted.add(next),
    );
    addTearDown(sub.close);

    await notifier.switchBranch(allBranchesSentinel);

    expect(emitted.any((state) => state.isLoading), isTrue);
    // No intermediate state may drop the value, or branch filters would flash
    // to "unfiltered" mid-switch.
    expect(emitted.every((state) => state.hasValue), isTrue);
    expect(
      emitted
          .where((state) => state.isLoading)
          .every((state) => state.value?.branch?.id == 'branch-a'),
      isTrue,
    );
    expect(emitted.last.value?.isAll, isTrue);
  });

  test('non-admin cannot switch to All or disallowed branch', () async {
    final container = createContainer(
      admin: false,
      allowed: ['branch-a'],
      persisted: 'branch-a',
    );
    addTearDown(container.dispose);
    await container.read(currentBranchControllerProvider.future);
    final notifier = container.read(currentBranchControllerProvider.notifier);

    await notifier.switchBranch(allBranchesSentinel);
    expect(container.read(currentBranchControllerProvider).value?.isAll, isFalse);

    await notifier.switchBranch('branch-b');
    expect(
      container.read(currentBranchControllerProvider).value?.branch?.id,
      'branch-a',
    );
  });

  test('switchableBranchIds returns all for admin', () async {
    final container = createContainer(admin: true);
    addTearDown(container.dispose);
    await container.read(currentBranchControllerProvider.future);
    final ids = await container
        .read(currentBranchControllerProvider.notifier)
        .switchableBranchIds();
    expect(ids, ['branch-a', 'branch-b']);
  });
}
