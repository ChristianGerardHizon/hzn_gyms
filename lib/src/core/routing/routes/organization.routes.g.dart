// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $organizationShellRoute,
    ];

RouteBase get $organizationShellRoute => ShellRouteData.$route(
      factory: $OrganizationShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/organization',
          factory: $OrganizationRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'users',
              factory: $OrganizationUsersRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $OrganizationUserDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'roles',
              factory: $OrganizationRolesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $OrganizationRoleDetailRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'branches',
              factory: $OrganizationBranchesRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':id',
                  factory: $OrganizationBranchDetailRoute._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    );

extension $OrganizationShellRouteExtension on OrganizationShellRoute {
  static OrganizationShellRoute _fromState(GoRouterState state) =>
      const OrganizationShellRoute();
}

mixin $OrganizationRoute on GoRouteData {
  static OrganizationRoute _fromState(GoRouterState state) =>
      const OrganizationRoute();

  @override
  String get location => GoRouteData.$location(
        '/organization',
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

mixin $OrganizationUsersRoute on GoRouteData {
  static OrganizationUsersRoute _fromState(GoRouterState state) =>
      const OrganizationUsersRoute();

  @override
  String get location => GoRouteData.$location(
        '/organization/users',
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

mixin $OrganizationUserDetailRoute on GoRouteData {
  static OrganizationUserDetailRoute _fromState(GoRouterState state) =>
      OrganizationUserDetailRoute(
        id: state.pathParameters['id']!,
        tab: state.uri.queryParameters['tab'],
      );

  OrganizationUserDetailRoute get _self => this as OrganizationUserDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/organization/users/${Uri.encodeComponent(_self.id)}',
        queryParams: {
          if (_self.tab != null) 'tab': _self.tab,
        },
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

mixin $OrganizationRolesRoute on GoRouteData {
  static OrganizationRolesRoute _fromState(GoRouterState state) =>
      const OrganizationRolesRoute();

  @override
  String get location => GoRouteData.$location(
        '/organization/roles',
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

mixin $OrganizationRoleDetailRoute on GoRouteData {
  static OrganizationRoleDetailRoute _fromState(GoRouterState state) =>
      OrganizationRoleDetailRoute(
        id: state.pathParameters['id']!,
      );

  OrganizationRoleDetailRoute get _self => this as OrganizationRoleDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/organization/roles/${Uri.encodeComponent(_self.id)}',
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

mixin $OrganizationBranchesRoute on GoRouteData {
  static OrganizationBranchesRoute _fromState(GoRouterState state) =>
      const OrganizationBranchesRoute();

  @override
  String get location => GoRouteData.$location(
        '/organization/branches',
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

mixin $OrganizationBranchDetailRoute on GoRouteData {
  static OrganizationBranchDetailRoute _fromState(GoRouterState state) =>
      OrganizationBranchDetailRoute(
        id: state.pathParameters['id']!,
      );

  OrganizationBranchDetailRoute get _self =>
      this as OrganizationBranchDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/organization/branches/${Uri.encodeComponent(_self.id)}',
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
