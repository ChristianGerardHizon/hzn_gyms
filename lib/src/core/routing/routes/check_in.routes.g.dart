// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$checkInRoute];

RouteBase get $checkInRoute => GoRouteData.$route(
  path: '/check-in',
  hasOverriddenOnExit: false,
  factory: $CheckInRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'records',
      hasOverriddenOnExit: false,
      factory: $CheckInRecordsRoute._fromState,
    ),
  ],
);

mixin $CheckInRoute on GoRouteData {
  static CheckInRoute _fromState(GoRouterState state) => const CheckInRoute();

  @override
  String get location => GoRouteData.$location('/check-in');

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

mixin $CheckInRecordsRoute on GoRouteData {
  static CheckInRecordsRoute _fromState(GoRouterState state) =>
      const CheckInRecordsRoute();

  @override
  String get location => GoRouteData.$location('/check-in/records');

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
