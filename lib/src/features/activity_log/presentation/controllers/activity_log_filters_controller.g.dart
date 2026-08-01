// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mutable filter state for the activity log list.

@ProviderFor(ActivityLogFiltersController)
final activityLogFiltersControllerProvider =
    ActivityLogFiltersControllerProvider._();

/// Mutable filter state for the activity log list.
final class ActivityLogFiltersControllerProvider
    extends $NotifierProvider<ActivityLogFiltersController, ActivityLogQuery> {
  /// Mutable filter state for the activity log list.
  ActivityLogFiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityLogFiltersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityLogFiltersControllerHash();

  @$internal
  @override
  ActivityLogFiltersController create() => ActivityLogFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityLogQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityLogQuery>(value),
    );
  }
}

String _$activityLogFiltersControllerHash() =>
    r'90169f5e927d115bad26fa5a234e1b7c46b73101';

/// Mutable filter state for the activity log list.

abstract class _$ActivityLogFiltersController
    extends $Notifier<ActivityLogQuery> {
  ActivityLogQuery build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ActivityLogQuery, ActivityLogQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActivityLogQuery, ActivityLogQuery>,
              ActivityLogQuery,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
