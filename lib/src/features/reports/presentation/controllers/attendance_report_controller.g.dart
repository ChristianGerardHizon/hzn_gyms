// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and caches attendance report data.

@ProviderFor(attendanceReport)
final attendanceReportProvider = AttendanceReportProvider._();

/// Fetches and caches attendance report data.

final class AttendanceReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttendanceReport>,
          AttendanceReport,
          FutureOr<AttendanceReport>
        >
    with $FutureModifier<AttendanceReport>, $FutureProvider<AttendanceReport> {
  /// Fetches and caches attendance report data.
  AttendanceReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceReportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceReportHash();

  @$internal
  @override
  $FutureProviderElement<AttendanceReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AttendanceReport> create(Ref ref) {
    return attendanceReport(ref);
  }
}

String _$attendanceReportHash() => r'3a764c00330bd364b14b6c2ef536f14f4e4f78be';
