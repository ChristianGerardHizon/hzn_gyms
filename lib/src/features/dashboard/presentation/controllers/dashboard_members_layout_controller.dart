import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/dashboard_members_layout.dart';

part 'dashboard_members_layout_controller.g.dart';

/// Storage key for dashboard members column count (Drift app_preferences).
const dashboardMembersColumnsKey = 'DASHBOARD_MEMBERS_COLUMNS';

/// Storage key for dashboard members photo visibility (Drift app_preferences).
const dashboardMembersShowPhotoKey = 'DASHBOARD_MEMBERS_SHOW_PHOTO';

/// Controller for dashboard members grid layout preferences.
///
/// Persists column count (1–5) and photo vs name-only display in Drift so the
/// choice survives app restarts. Effective columns are capped by screen width
/// at display time.
@Riverpod(keepAlive: true)
class DashboardMembersLayoutController
    extends _$DashboardMembersLayoutController {
  @override
  Future<DashboardMembersLayout> build() async {
    return await _loadPersistedLayout() ?? const DashboardMembersLayout();
  }

  /// Sets the grid column count and persists the preference.
  Future<void> setColumns(int columns) async {
    final current = state.value ?? const DashboardMembersLayout();
    final next = current.copyWith(columns: columns);
    await _persistLayout(next);
    state = AsyncData(next);
  }

  /// Sets whether member photos are shown and persists the preference.
  Future<void> setShowPhoto(bool showPhoto) async {
    final current = state.value ?? const DashboardMembersLayout();
    final next = current.copyWith(showPhoto: showPhoto);
    await _persistLayout(next);
    state = AsyncData(next);
  }

  Future<DashboardMembersLayout?> _loadPersistedLayout() async {
    final prefs = ref.read(appDatabaseProvider).appPreferencesDao;
    final columnsRaw = await prefs.getValue(dashboardMembersColumnsKey);
    final showPhotoRaw = await prefs.getValue(dashboardMembersShowPhotoKey);

    if (columnsRaw == null && showPhotoRaw == null) return null;

    final columns = columnsRaw != null
        ? DashboardMembersLayout.clampColumns(
            int.tryParse(columnsRaw) ?? DashboardMembersLayout.defaultColumns,
          )
        : DashboardMembersLayout.defaultColumns;

    final showPhoto = showPhotoRaw == null
        ? true
        : showPhotoRaw.toLowerCase() != 'false';

    return DashboardMembersLayout(columns: columns, showPhoto: showPhoto);
  }

  Future<void> _persistLayout(DashboardMembersLayout layout) async {
    final prefs = ref.read(appDatabaseProvider).appPreferencesDao;
    await prefs.setValues({
      dashboardMembersColumnsKey: layout.columns.toString(),
      dashboardMembersShowPhotoKey: layout.showPhoto.toString(),
    });
  }
}

/// Convenience provider for current layout (defaults while loading).
@Riverpod(keepAlive: true)
DashboardMembersLayout currentDashboardMembersLayout(Ref ref) {
  return ref.watch(dashboardMembersLayoutControllerProvider).value ??
      const DashboardMembersLayout();
}
