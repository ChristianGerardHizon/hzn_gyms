// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roles.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$rolesRoute];

RouteBase get $rolesRoute =>
    GoRouteData.$route(path: '/roles', factory: $RolesRoute._fromState);

mixin $RolesRoute on GoRouteData {
  static RolesRoute _fromState(GoRouterState state) => const RolesRoute();

  @override
  String get location => GoRouteData.$location('/roles');

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
