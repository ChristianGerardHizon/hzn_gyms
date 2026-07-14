// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$productsShellRoute];

RouteBase get $productsShellRoute => ShellRouteData.$route(
  factory: $ProductsShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/products',
      factory: $ProductsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':id',
          factory: $ProductDetailRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $ProductsShellRouteExtension on ProductsShellRoute {
  static ProductsShellRoute _fromState(GoRouterState state) =>
      const ProductsShellRoute();
}

mixin $ProductsRoute on GoRouteData {
  static ProductsRoute _fromState(GoRouterState state) => const ProductsRoute();

  @override
  String get location => GoRouteData.$location('/products');

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

mixin $ProductDetailRoute on GoRouteData {
  static ProductDetailRoute _fromState(GoRouterState state) =>
      ProductDetailRoute(
        id: state.pathParameters['id']!,
        tab: state.uri.queryParameters['tab'],
      );

  ProductDetailRoute get _self => this as ProductDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/products/${Uri.encodeComponent(_self.id)}',
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
