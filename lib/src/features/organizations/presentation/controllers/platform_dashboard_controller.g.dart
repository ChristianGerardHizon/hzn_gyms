// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Summary metrics for the platform admin dashboard.

@ProviderFor(platformDashboardSummary)
final platformDashboardSummaryProvider = PlatformDashboardSummaryProvider._();

/// Summary metrics for the platform admin dashboard.

final class PlatformDashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlatformDashboardSummary>,
          PlatformDashboardSummary,
          FutureOr<PlatformDashboardSummary>
        >
    with
        $FutureModifier<PlatformDashboardSummary>,
        $FutureProvider<PlatformDashboardSummary> {
  /// Summary metrics for the platform admin dashboard.
  PlatformDashboardSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformDashboardSummaryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformDashboardSummaryHash();

  @$internal
  @override
  $FutureProviderElement<PlatformDashboardSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlatformDashboardSummary> create(Ref ref) {
    return platformDashboardSummary(ref);
  }
}

String _$platformDashboardSummaryHash() =>
    r'cf4873b439a7840a5bcf07047cc41e78c77b0e66';

/// Recent organizations for the platform dashboard (newest first, max 5).

@ProviderFor(platformRecentOrganizations)
final platformRecentOrganizationsProvider =
    PlatformRecentOrganizationsProvider._();

/// Recent organizations for the platform dashboard (newest first, max 5).

final class PlatformRecentOrganizationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Organization>>,
          List<Organization>,
          FutureOr<List<Organization>>
        >
    with
        $FutureModifier<List<Organization>>,
        $FutureProvider<List<Organization>> {
  /// Recent organizations for the platform dashboard (newest first, max 5).
  PlatformRecentOrganizationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformRecentOrganizationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformRecentOrganizationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Organization>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Organization>> create(Ref ref) {
    return platformRecentOrganizations(ref);
  }
}

String _$platformRecentOrganizationsHash() =>
    r'dc555aa3ee839aa3ade284eee2436d363e49d006';
