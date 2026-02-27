// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches a single page of members with their membership status
/// from the [membersWithMembershipStatus] view collection.
///
/// Uses server-side pagination and filtering. A single API call
/// replaces the previous 3-call approach (members + active memberships
/// + all memberships).

@ProviderFor(dashboardMembersPage)
final dashboardMembersPageProvider = DashboardMembersPageFamily._();

/// Fetches a single page of members with their membership status
/// from the [membersWithMembershipStatus] view collection.
///
/// Uses server-side pagination and filtering. A single API call
/// replaces the previous 3-call approach (members + active memberships
/// + all memberships).

final class DashboardMembersPageProvider extends $FunctionalProvider<
        AsyncValue<DashboardMembersPage>,
        DashboardMembersPage,
        FutureOr<DashboardMembersPage>>
    with
        $FutureModifier<DashboardMembersPage>,
        $FutureProvider<DashboardMembersPage> {
  /// Fetches a single page of members with their membership status
  /// from the [membersWithMembershipStatus] view collection.
  ///
  /// Uses server-side pagination and filtering. A single API call
  /// replaces the previous 3-call approach (members + active memberships
  /// + all memberships).
  DashboardMembersPageProvider._(
      {required DashboardMembersPageFamily super.from,
      required ({
        int page,
        String? searchQuery,
        MemberStatusFilter statusFilter,
      })
          super.argument})
      : super(
          retry: null,
          name: r'dashboardMembersPageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardMembersPageHash();

  @override
  String toString() {
    return r'dashboardMembersPageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DashboardMembersPage> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardMembersPage> create(Ref ref) {
    final argument = this.argument as ({
      int page,
      String? searchQuery,
      MemberStatusFilter statusFilter,
    });
    return dashboardMembersPage(
      ref,
      page: argument.page,
      searchQuery: argument.searchQuery,
      statusFilter: argument.statusFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardMembersPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardMembersPageHash() =>
    r'6aab100a3d351c434740d309e5084934c1c9ef3f';

/// Fetches a single page of members with their membership status
/// from the [membersWithMembershipStatus] view collection.
///
/// Uses server-side pagination and filtering. A single API call
/// replaces the previous 3-call approach (members + active memberships
/// + all memberships).

final class DashboardMembersPageFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<DashboardMembersPage>,
            ({
              int page,
              String? searchQuery,
              MemberStatusFilter statusFilter,
            })> {
  DashboardMembersPageFamily._()
      : super(
          retry: null,
          name: r'dashboardMembersPageProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches a single page of members with their membership status
  /// from the [membersWithMembershipStatus] view collection.
  ///
  /// Uses server-side pagination and filtering. A single API call
  /// replaces the previous 3-call approach (members + active memberships
  /// + all memberships).

  DashboardMembersPageProvider call({
    int page = 1,
    String? searchQuery,
    MemberStatusFilter statusFilter = MemberStatusFilter.all,
  }) =>
      DashboardMembersPageProvider._(argument: (
        page: page,
        searchQuery: searchQuery,
        statusFilter: statusFilter,
      ), from: this);

  @override
  String toString() => r'dashboardMembersPageProvider';
}
