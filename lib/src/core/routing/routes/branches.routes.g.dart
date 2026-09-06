// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$branchesShellRoute];

RouteBase get $branchesShellRoute => ShellRouteData.$route(
  factory: $BranchesShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/branches',
      hasOverriddenOnExit: false,
      factory: $BranchesRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':id',
          hasOverriddenOnExit: false,
          factory: $BranchDetailRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $BranchesShellRouteExtension on BranchesShellRoute {
  static BranchesShellRoute _fromState(GoRouterState state) =>
      const BranchesShellRoute();
}

mixin $BranchesRoute on GoRouteData {
  static BranchesRoute _fromState(GoRouterState state) => const BranchesRoute();

  @override
  String get location => GoRouteData.$location('/branches');

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

mixin $BranchDetailRoute on GoRouteData {
  static BranchDetailRoute _fromState(GoRouterState state) =>
      BranchDetailRoute(id: state.pathParameters['id']!);

  BranchDetailRoute get _self => this as BranchDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/branches/${Uri.encodeComponent(_self.id)}');

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
