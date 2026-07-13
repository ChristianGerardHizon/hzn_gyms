// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_members_layout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for dashboard members grid layout preferences.
///
/// Persists column count (1–5) and photo vs name-only display in Drift so the
/// choice survives app restarts. Effective columns are capped by screen width
/// at display time.

@ProviderFor(DashboardMembersLayoutController)
final dashboardMembersLayoutControllerProvider =
    DashboardMembersLayoutControllerProvider._();

/// Controller for dashboard members grid layout preferences.
///
/// Persists column count (1–5) and photo vs name-only display in Drift so the
/// choice survives app restarts. Effective columns are capped by screen width
/// at display time.
final class DashboardMembersLayoutControllerProvider
    extends
        $AsyncNotifierProvider<
          DashboardMembersLayoutController,
          DashboardMembersLayout
        > {
  /// Controller for dashboard members grid layout preferences.
  ///
  /// Persists column count (1–5) and photo vs name-only display in Drift so the
  /// choice survives app restarts. Effective columns are capped by screen width
  /// at display time.
  DashboardMembersLayoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardMembersLayoutControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardMembersLayoutControllerHash();

  @$internal
  @override
  DashboardMembersLayoutController create() =>
      DashboardMembersLayoutController();
}

String _$dashboardMembersLayoutControllerHash() =>
    r'53cf09357c97d7279aaffa6744cf556d2f62e944';

/// Controller for dashboard members grid layout preferences.
///
/// Persists column count (1–5) and photo vs name-only display in Drift so the
/// choice survives app restarts. Effective columns are capped by screen width
/// at display time.

abstract class _$DashboardMembersLayoutController
    extends $AsyncNotifier<DashboardMembersLayout> {
  FutureOr<DashboardMembersLayout> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<DashboardMembersLayout>, DashboardMembersLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DashboardMembersLayout>,
                DashboardMembersLayout
              >,
              AsyncValue<DashboardMembersLayout>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Convenience provider for current layout (defaults while loading).

@ProviderFor(currentDashboardMembersLayout)
final currentDashboardMembersLayoutProvider =
    CurrentDashboardMembersLayoutProvider._();

/// Convenience provider for current layout (defaults while loading).

final class CurrentDashboardMembersLayoutProvider
    extends
        $FunctionalProvider<
          DashboardMembersLayout,
          DashboardMembersLayout,
          DashboardMembersLayout
        >
    with $Provider<DashboardMembersLayout> {
  /// Convenience provider for current layout (defaults while loading).
  CurrentDashboardMembersLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDashboardMembersLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDashboardMembersLayoutHash();

  @$internal
  @override
  $ProviderElement<DashboardMembersLayout> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardMembersLayout create(Ref ref) {
    return currentDashboardMembersLayout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardMembersLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardMembersLayout>(value),
    );
  }
}

String _$currentDashboardMembersLayoutHash() =>
    r'70507d0b9f61ed51eba55655544c6a0843332c06';
