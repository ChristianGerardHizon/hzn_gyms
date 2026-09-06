// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$salesShellRoute];

RouteBase get $salesShellRoute => ShellRouteData.$route(
  factory: $SalesShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/sales',
      hasOverriddenOnExit: false,
      factory: $SalesHistoryRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':id',
          hasOverriddenOnExit: false,
          factory: $SaleDetailRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $SalesShellRouteExtension on SalesShellRoute {
  static SalesShellRoute _fromState(GoRouterState state) =>
      const SalesShellRoute();
}

mixin $SalesHistoryRoute on GoRouteData {
  static SalesHistoryRoute _fromState(GoRouterState state) =>
      const SalesHistoryRoute();

  @override
  String get location => GoRouteData.$location('/sales');

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

mixin $SaleDetailRoute on GoRouteData {
  static SaleDetailRoute _fromState(GoRouterState state) =>
      SaleDetailRoute(id: state.pathParameters['id']!);

  SaleDetailRoute get _self => this as SaleDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/sales/${Uri.encodeComponent(_self.id)}');

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
