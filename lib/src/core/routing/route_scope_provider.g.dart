// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_scope_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(CurrentRouteScope)
final currentRouteScopeProvider = CurrentRouteScopeProvider._();

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
final class CurrentRouteScopeProvider
    extends $NotifierProvider<CurrentRouteScope, RouteScope?> {
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
  CurrentRouteScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentRouteScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentRouteScopeHash();

  @$internal
  @override
  CurrentRouteScope create() => CurrentRouteScope();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteScope? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteScope?>(value),
    );
  }
}

String _$currentRouteScopeHash() => r'aed9084731ce98aad74a4c81780eb4bc81b2c391';

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

abstract class _$CurrentRouteScope extends $Notifier<RouteScope?> {
  RouteScope? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RouteScope?, RouteScope?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RouteScope?, RouteScope?>,
              RouteScope?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
