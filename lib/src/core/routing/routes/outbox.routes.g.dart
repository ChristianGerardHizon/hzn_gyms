// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$outboxRoute];

RouteBase get $outboxRoute =>
    GoRouteData.$route(path: '/outbox', factory: $OutboxRoute._fromState);

mixin $OutboxRoute on GoRouteData {
  static OutboxRoute _fromState(GoRouterState state) => const OutboxRoute();

  @override
  String get location => GoRouteData.$location('/outbox');

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
