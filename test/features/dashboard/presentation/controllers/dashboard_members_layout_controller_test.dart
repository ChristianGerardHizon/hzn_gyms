import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_gyms/src/core/database/app_database.dart';
import 'package:hzn_gyms/src/core/database/database_provider.dart';
import 'package:hzn_gyms/src/features/dashboard/domain/dashboard_members_layout.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/dashboard_members_layout_controller.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  }

  test('defaults when nothing is persisted', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final layout =
        await container.read(dashboardMembersLayoutControllerProvider.future);

    expect(layout, const DashboardMembersLayout());
    expect(
      container.read(currentDashboardMembersLayoutProvider),
      const DashboardMembersLayout(),
    );
  });

  test('loads persisted columns and showPhoto from Drift', () async {
    await db.appPreferencesDao.setValues({
      dashboardMembersColumnsKey: '3',
      dashboardMembersShowPhotoKey: 'false',
    });

    final container = createContainer();
    addTearDown(container.dispose);

    final layout =
        await container.read(dashboardMembersLayoutControllerProvider.future);

    expect(layout.columns, 3);
    expect(layout.showPhoto, isFalse);
  });

  test('clamps invalid persisted column count', () async {
    await db.appPreferencesDao.setValue(dashboardMembersColumnsKey, '99');

    final container = createContainer();
    addTearDown(container.dispose);

    final layout =
        await container.read(dashboardMembersLayoutControllerProvider.future);

    expect(layout.columns, DashboardMembersLayout.defaultColumns);
    expect(layout.showPhoto, isTrue);
  });

  test('setColumns persists in Drift and updates state', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(dashboardMembersLayoutControllerProvider.future);
    await container
        .read(dashboardMembersLayoutControllerProvider.notifier)
        .setColumns(5);

    expect(
      await db.appPreferencesDao.getValue(dashboardMembersColumnsKey),
      '5',
    );
    expect(
      container.read(currentDashboardMembersLayoutProvider).columns,
      5,
    );
  });

  test('setShowPhoto persists in Drift and updates state', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(dashboardMembersLayoutControllerProvider.future);
    await container
        .read(dashboardMembersLayoutControllerProvider.notifier)
        .setShowPhoto(false);

    expect(
      await db.appPreferencesDao.getValue(dashboardMembersShowPhotoKey),
      'false',
    );
    expect(
      container.read(currentDashboardMembersLayoutProvider).showPhoto,
      isFalse,
    );
  });

  test('persisted layout survives a new controller session', () async {
    final first = createContainer();
    addTearDown(first.dispose);

    await first.read(dashboardMembersLayoutControllerProvider.future);
    await first
        .read(dashboardMembersLayoutControllerProvider.notifier)
        .setColumns(2);
    await first
        .read(dashboardMembersLayoutControllerProvider.notifier)
        .setShowPhoto(false);
    first.dispose();

    final second = createContainer();
    addTearDown(second.dispose);

    final layout =
        await second.read(dashboardMembersLayoutControllerProvider.future);
    expect(layout.columns, 2);
    expect(layout.showPhoto, isFalse);
  });
}
