// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $membersShellRoute,
    ];

RouteBase get $membersShellRoute => ShellRouteData.$route(
      factory: $MembersShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/members',
          factory: $MembersRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $MemberDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $MembersShellRouteExtension on MembersShellRoute {
  static MembersShellRoute _fromState(GoRouterState state) =>
      const MembersShellRoute();
}

mixin $MembersRoute on GoRouteData {
  static MembersRoute _fromState(GoRouterState state) => const MembersRoute();

  @override
  String get location => GoRouteData.$location(
        '/members',
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

mixin $MemberDetailRoute on GoRouteData {
  static MemberDetailRoute _fromState(GoRouterState state) => MemberDetailRoute(
        id: state.pathParameters['id']!,
      );

  MemberDetailRoute get _self => this as MemberDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/members/${Uri.encodeComponent(_self.id)}',
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
