// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$reportsRoute];

RouteBase get $reportsRoute => GoRouteData.$route(
  path: '/reports',
  hasOverriddenOnExit: false,
  factory: $ReportsRoute._fromState,
);

mixin $ReportsRoute on GoRouteData {
  static ReportsRoute _fromState(GoRouterState state) => const ReportsRoute();

  @override
  String get location => GoRouteData.$location('/reports');

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
