// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roles.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$rolesRoute];

RouteBase get $rolesRoute => GoRouteData.$route(
  path: '/roles',
  hasOverriddenOnExit: false,
  factory: $RolesRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: ':id',
      hasOverriddenOnExit: false,
      factory: $RoleDetailRoute._fromState,
    ),
  ],
);

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

mixin $RoleDetailRoute on GoRouteData {
  static RoleDetailRoute _fromState(GoRouterState state) =>
      RoleDetailRoute(id: state.pathParameters['id']!);

  RoleDetailRoute get _self => this as RoleDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/roles/${Uri.encodeComponent(_self.id)}');

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
