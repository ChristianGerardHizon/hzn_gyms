// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activityLog)
final activityLogProvider = ActivityLogFamily._();

final class ActivityLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActivityLog>,
          ActivityLog,
          FutureOr<ActivityLog>
        >
    with $FutureModifier<ActivityLog>, $FutureProvider<ActivityLog> {
  ActivityLogProvider._({
    required ActivityLogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activityLogProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activityLogHash();

  @override
  String toString() {
    return r'activityLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ActivityLog> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ActivityLog> create(Ref ref) {
    final argument = this.argument as String;
    return activityLog(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activityLogHash() => r'42b4f3c82ab33fba728df0d829833bc4278f2fdf';

final class ActivityLogFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ActivityLog>, String> {
  ActivityLogFamily._()
    : super(
        retry: null,
        name: r'activityLogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActivityLogProvider call(String id) =>
      ActivityLogProvider._(argument: id, from: this);

  @override
  String toString() => r'activityLogProvider';
}
