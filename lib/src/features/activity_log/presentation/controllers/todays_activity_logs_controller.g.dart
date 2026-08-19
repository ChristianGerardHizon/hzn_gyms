// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_activity_logs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Paginated activity logs for the local calendar day.
///
/// Follows the global branch selector. Independent of the System page
/// 7-day filter controller.

@ProviderFor(TodaysActivityLogsController)
final todaysActivityLogsControllerProvider =
    TodaysActivityLogsControllerProvider._();

/// Paginated activity logs for the local calendar day.
///
/// Follows the global branch selector. Independent of the System page
/// 7-day filter controller.
final class TodaysActivityLogsControllerProvider
    extends
        $AsyncNotifierProvider<
          TodaysActivityLogsController,
          PaginatedState<ActivityLog>
        > {
  /// Paginated activity logs for the local calendar day.
  ///
  /// Follows the global branch selector. Independent of the System page
  /// 7-day filter controller.
  TodaysActivityLogsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysActivityLogsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysActivityLogsControllerHash();

  @$internal
  @override
  TodaysActivityLogsController create() => TodaysActivityLogsController();
}

String _$todaysActivityLogsControllerHash() =>
    r'f51846a57a6585a8b26ac375dd40147bd8f7ba4c';

/// Paginated activity logs for the local calendar day.
///
/// Follows the global branch selector. Independent of the System page
/// 7-day filter controller.

abstract class _$TodaysActivityLogsController
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
