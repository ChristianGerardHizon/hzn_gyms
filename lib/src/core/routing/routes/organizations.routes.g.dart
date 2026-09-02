// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizations.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$organizationsRoute];

RouteBase get $organizationsRoute => GoRouteData.$route(
  path: '/organizations',
  hasOverriddenOnExit: false,
  factory: $OrganizationsRoute._fromState,
);

mixin $OrganizationsRoute on GoRouteData {
  static OrganizationsRoute _fromState(GoRouterState state) =>
      const OrganizationsRoute();

  @override
  String get location => GoRouteData.$location('/organizations');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
