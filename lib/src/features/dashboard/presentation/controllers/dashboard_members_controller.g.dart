// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All members with their latest active membership attached.
///
/// Sorted with near-expiration members first, then active, then no membership.

@ProviderFor(dashboardMembers)
final dashboardMembersProvider = DashboardMembersProvider._();

/// All members with their latest active membership attached.
///
/// Sorted with near-expiration members first, then active, then no membership.

final class DashboardMembersProvider extends $FunctionalProvider<
        AsyncValue<List<DashboardMember>>,
        List<DashboardMember>,
        FutureOr<List<DashboardMember>>>
    with
        $FutureModifier<List<DashboardMember>>,
        $FutureProvider<List<DashboardMember>> {
  /// All members with their latest active membership attached.
  ///
  /// Sorted with near-expiration members first, then active, then no membership.
  DashboardMembersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardMembersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<DashboardMember>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<DashboardMember>> create(Ref ref) {
    return dashboardMembers(ref);
  }
}

String _$dashboardMembersHash() => r'a2ac3d7b8798c17ea8765d6eb2cf5d8cfd0f473f';
