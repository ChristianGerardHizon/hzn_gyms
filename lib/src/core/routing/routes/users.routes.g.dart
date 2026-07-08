// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$usersShellRoute];

RouteBase get $usersShellRoute => ShellRouteData.$route(
  factory: $UsersShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/users',
      factory: $UsersRoute._fromState,
      routes: [
        GoRouteData.$route(path: ':id', factory: $UserDetailRoute._fromState),
        GoRouteData.$route(path: 'roles', factory: $UserRolesRoute._fromState),
      ],
    ),
  ],
);

extension $UsersShellRouteExtension on UsersShellRoute {
  static UsersShellRoute _fromState(GoRouterState state) =>
      const UsersShellRoute();
}

mixin $UsersRoute on GoRouteData {
  static UsersRoute _fromState(GoRouterState state) => const UsersRoute();

  @override
  String get location => GoRouteData.$location('/users');

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

mixin $UserDetailRoute on GoRouteData {
  static UserDetailRoute _fromState(GoRouterState state) => UserDetailRoute(
    id: state.pathParameters['id']!,
    tab: state.uri.queryParameters['tab'],
  );

  UserDetailRoute get _self => this as UserDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.id)}',
    queryParams: {if (_self.tab != null) 'tab': _self.tab},
  );

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

mixin $UserRolesRoute on GoRouteData {
  static UserRolesRoute _fromState(GoRouterState state) =>
      const UserRolesRoute();

  @override
  String get location => GoRouteData.$location('/users/roles');

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
