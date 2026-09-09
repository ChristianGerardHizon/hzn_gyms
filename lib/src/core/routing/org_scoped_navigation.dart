import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers for [GoRouteData] classes nested under the
/// `/:orgSlug/:branchSlug` prefix in `router.dart`.
///
/// The prefix is a hand-written [GoRoute], outside every feature route
/// file's own `@TypedGoRoute`/`@TypedShellRoute` tree, so the codegen'd
/// `.location`/`.go`/`.push` on those classes are unprefixed (e.g.
/// `/members`) and would 404 if navigated to directly. These helpers read
/// the current `orgSlug`/`branchSlug` off the ambient [GoRouterState] and
/// prepend them — safe because anything calling one of these is already
/// running from a page under `/:orgSlug/:branchSlug/...`.
extension OrgScopedGoRouteData on GoRouteData {
  String _scopedLocation(BuildContext context) {
    final params = GoRouterState.of(context).pathParameters;
    final orgSlug = params['orgSlug'];
    final branchSlug = params['branchSlug'];
    assert(
      orgSlug != null && branchSlug != null,
      'goScoped/pushScoped used outside org/branch route scope for $location',
    );
    return '/$orgSlug/$branchSlug$location';
  }

  /// Like [GoRouteData.go], but prefixed with the current org/branch scope.
  void goScoped(BuildContext context) => context.go(_scopedLocation(context));

  /// Like [GoRouteData.push], but prefixed with the current org/branch scope.
  Future<T?> pushScoped<T>(BuildContext context) =>
      context.push<T>(_scopedLocation(context));

  /// Like [GoRouteData.pushReplacement], but prefixed with the current
  /// org/branch scope.
  void pushReplacementScoped(BuildContext context) =>
      context.pushReplacement(_scopedLocation(context));

  /// Like [GoRouteData.replace], but prefixed with the current org/branch
  /// scope.
  void replaceScoped(BuildContext context) =>
      context.replace(_scopedLocation(context));
}
