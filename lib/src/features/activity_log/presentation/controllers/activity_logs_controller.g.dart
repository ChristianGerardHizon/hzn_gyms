// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_logs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Paginated activity log list controller.

@ProviderFor(ActivityLogsController)
final activityLogsControllerProvider = ActivityLogsControllerProvider._();

/// Paginated activity log list controller.
final class ActivityLogsControllerProvider
    extends
        $AsyncNotifierProvider<
          ActivityLogsController,
          PaginatedState<ActivityLog>
        > {
  /// Paginated activity log list controller.
  ActivityLogsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityLogsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityLogsControllerHash();

  @$internal
  @override
  ActivityLogsController create() => ActivityLogsController();
}

String _$activityLogsControllerHash() =>
    r'09d4358db74ebd9c91b5cf80478463321779f411';

/// Paginated activity log list controller.

abstract class _$ActivityLogsController
    extends $AsyncNotifier<PaginatedState<ActivityLog>> {
  FutureOr<PaginatedState<ActivityLog>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedState<ActivityLog>>,
              PaginatedState<ActivityLog>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<ActivityLog>>,
                PaginatedState<ActivityLog>
              >,
              AsyncValue<PaginatedState<ActivityLog>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
