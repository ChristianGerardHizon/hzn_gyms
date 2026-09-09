import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_scope_provider.g.dart';

/// The `orgSlug`/`branchSlug` segments of the currently-active URL, once
/// [RouterUtils.redirect] has validated them against real records.
class RouteScope {
  const RouteScope({required this.orgSlug, required this.branchSlug});

  final String orgSlug;
  final String branchSlug;

  @override
  bool operator ==(Object other) =>
      other is RouteScope &&
      other.orgSlug == orgSlug &&
      other.branchSlug == branchSlug;

  @override
  int get hashCode => Object.hash(orgSlug, branchSlug);
}

/// Holds the last-validated org/branch route scope.
///
/// Set exclusively by [RouterUtils.redirect] once it confirms the URL's
/// `orgSlug`/`branchSlug` segments resolve to records the current user may
/// access. [CurrentBranchController] watches this to make the URL the
/// source of truth for the working branch. Organization is intentionally
/// NOT re-resolved from this — switching org requires a server-side
/// `users.organization` patch (see [CurrentOrganizationController]), so the
/// route segment for org is validated/self-healing only, never a trigger to
/// silently switch tenants.
@Riverpod(keepAlive: true)
class CurrentRouteScope extends _$CurrentRouteScope {
  @override
  RouteScope? build() => null;

  void set(String orgSlug, String branchSlug) {
    final next = RouteScope(orgSlug: orgSlug, branchSlug: branchSlug);
    if (state != next) state = next;
  }

  void clear() {
    if (state != null) state = null;
  }
}
