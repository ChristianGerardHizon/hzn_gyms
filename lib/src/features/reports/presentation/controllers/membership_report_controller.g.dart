// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and provides membership report data.

@ProviderFor(membershipReport)
final membershipReportProvider = MembershipReportProvider._();

/// Fetches and provides membership report data.

final class MembershipReportProvider extends $FunctionalProvider<
        AsyncValue<MembershipReport>,
        MembershipReport,
        FutureOr<MembershipReport>>
    with $FutureModifier<MembershipReport>, $FutureProvider<MembershipReport> {
  /// Fetches and provides membership report data.
  MembershipReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'membershipReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$membershipReportHash();

  @$internal
  @override
  $FutureProviderElement<MembershipReport> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MembershipReport> create(Ref ref) {
    return membershipReport(ref);
  }
}

String _$membershipReportHash() => r'6ccff289e167654f9f8e14a04d8eb2aadeb074f9';
