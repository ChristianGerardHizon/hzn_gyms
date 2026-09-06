// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$platformShellRoute];

RouteBase get $platformShellRoute => ShellRouteData.$route(
  factory: $PlatformShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/platform',
      hasOverriddenOnExit: false,
      factory: $PlatformDashboardRoute._fromState,
    ),
    GoRouteData.$route(
      path: '/platform/organizations',
      hasOverriddenOnExit: false,
      factory: $PlatformOrganizationsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':orgId/setup',
          hasOverriddenOnExit: false,
          factory: $OrganizationSetupRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $PlatformShellRouteExtension on PlatformShellRoute {
  static PlatformShellRoute _fromState(GoRouterState state) =>
      const PlatformShellRoute();
}

mixin $PlatformDashboardRoute on GoRouteData {
  static PlatformDashboardRoute _fromState(GoRouterState state) =>
      const PlatformDashboardRoute();

  @override
  String get location => GoRouteData.$location('/platform');

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

mixin $PlatformOrganizationsRoute on GoRouteData {
  static PlatformOrganizationsRoute _fromState(GoRouterState state) =>
      const PlatformOrganizationsRoute();

  @override
  String get location => GoRouteData.$location('/platform/organizations');

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

mixin $OrganizationSetupRoute on GoRouteData {
  static OrganizationSetupRoute _fromState(GoRouterState state) =>
      OrganizationSetupRoute(orgId: state.pathParameters['orgId']!);

  OrganizationSetupRoute get _self => this as OrganizationSetupRoute;

  @override
  String get location => GoRouteData.$location(
    '/platform/organizations/${Uri.encodeComponent(_self.orgId)}/setup',
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
