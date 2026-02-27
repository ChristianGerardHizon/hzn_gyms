// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberships.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $membershipsShellRoute,
    ];

RouteBase get $membershipsShellRoute => ShellRouteData.$route(
      factory: $MembershipsShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/memberships',
          factory: $MembershipsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $MembershipDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $MembershipsShellRouteExtension on MembershipsShellRoute {
  static MembershipsShellRoute _fromState(GoRouterState state) =>
      const MembershipsShellRoute();
}

mixin $MembershipsRoute on GoRouteData {
  static MembershipsRoute _fromState(GoRouterState state) =>
      const MembershipsRoute();

  @override
  String get location => GoRouteData.$location(
        '/memberships',
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

mixin $MembershipDetailRoute on GoRouteData {
  static MembershipDetailRoute _fromState(GoRouterState state) =>
      MembershipDetailRoute(
        id: state.pathParameters['id']!,
      );

  MembershipDetailRoute get _self => this as MembershipDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/memberships/${Uri.encodeComponent(_self.id)}',
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
