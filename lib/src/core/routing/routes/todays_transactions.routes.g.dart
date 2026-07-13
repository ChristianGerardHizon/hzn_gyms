// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_transactions.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$todaysTransactionsRoute];

RouteBase get $todaysTransactionsRoute => GoRouteData.$route(
  path: '/todays-transactions',
  factory: $TodaysTransactionsRoute._fromState,
);

mixin $TodaysTransactionsRoute on GoRouteData {
  static TodaysTransactionsRoute _fromState(GoRouterState state) =>
      const TodaysTransactionsRoute();

  @override
  String get location => GoRouteData.$location('/todays-transactions');

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
