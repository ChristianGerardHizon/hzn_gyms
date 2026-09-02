// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$salesRoute];

RouteBase get $salesRoute => GoRouteData.$route(
  path: '/cashier',
  hasOverriddenOnExit: false,
  factory: $SalesRoute._fromState,
);

mixin $SalesRoute on GoRouteData {
  static SalesRoute _fromState(GoRouterState state) => const SalesRoute();

  @override
  String get location => GoRouteData.$location('/cashier');

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
