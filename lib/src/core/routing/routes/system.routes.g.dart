// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system.routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$systemShellRoute];

RouteBase get $systemShellRoute => ShellRouteData.$route(
  factory: $SystemShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/system',
      factory: $SystemRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'product-categories',
          factory: $ProductCategoriesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $ProductCategoryDetailRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'quantity-units',
          factory: $QuantityUnitsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $QuantityUnitDetailRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'printers',
          factory: $PrinterSettingsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $PrinterDetailRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'cashier-groups',
          factory: $CashierGroupsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $CashierGroupDetailRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'appearance',
          factory: $AppearanceRoute._fromState,
        ),
        GoRouteData.$route(path: 'import', factory: $ImportRoute._fromState),
        GoRouteData.$route(
          path: 'debug',
          factory: $SystemDebugRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'activity-log',
          factory: $ActivityLogRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              factory: $ActivityLogDetailRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $SystemShellRouteExtension on SystemShellRoute {
  static SystemShellRoute _fromState(GoRouterState state) =>
      const SystemShellRoute();
}

mixin $SystemRoute on GoRouteData {
  static SystemRoute _fromState(GoRouterState state) => const SystemRoute();

  @override
  String get location => GoRouteData.$location('/system');

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

mixin $ProductCategoriesRoute on GoRouteData {
  static ProductCategoriesRoute _fromState(GoRouterState state) =>
      const ProductCategoriesRoute();

  @override
  String get location => GoRouteData.$location('/system/product-categories');

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

mixin $ProductCategoryDetailRoute on GoRouteData {
  static ProductCategoryDetailRoute _fromState(GoRouterState state) =>
      ProductCategoryDetailRoute(id: state.pathParameters['id']!);

  ProductCategoryDetailRoute get _self => this as ProductCategoryDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/system/product-categories/${Uri.encodeComponent(_self.id)}',
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

mixin $QuantityUnitsRoute on GoRouteData {
  static QuantityUnitsRoute _fromState(GoRouterState state) =>
      const QuantityUnitsRoute();

  @override
  String get location => GoRouteData.$location('/system/quantity-units');

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

mixin $QuantityUnitDetailRoute on GoRouteData {
  static QuantityUnitDetailRoute _fromState(GoRouterState state) =>
      QuantityUnitDetailRoute(id: state.pathParameters['id']!);

  QuantityUnitDetailRoute get _self => this as QuantityUnitDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/system/quantity-units/${Uri.encodeComponent(_self.id)}',
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

mixin $PrinterSettingsRoute on GoRouteData {
  static PrinterSettingsRoute _fromState(GoRouterState state) =>
      const PrinterSettingsRoute();

  @override
  String get location => GoRouteData.$location('/system/printers');

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

mixin $PrinterDetailRoute on GoRouteData {
  static PrinterDetailRoute _fromState(GoRouterState state) =>
      PrinterDetailRoute(id: state.pathParameters['id']!);

  PrinterDetailRoute get _self => this as PrinterDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/system/printers/${Uri.encodeComponent(_self.id)}',
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

mixin $CashierGroupsRoute on GoRouteData {
  static CashierGroupsRoute _fromState(GoRouterState state) =>
      const CashierGroupsRoute();

  @override
  String get location => GoRouteData.$location('/system/cashier-groups');

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

mixin $CashierGroupDetailRoute on GoRouteData {
  static CashierGroupDetailRoute _fromState(GoRouterState state) =>
      CashierGroupDetailRoute(id: state.pathParameters['id']!);

  CashierGroupDetailRoute get _self => this as CashierGroupDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/system/cashier-groups/${Uri.encodeComponent(_self.id)}',
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

mixin $AppearanceRoute on GoRouteData {
  static AppearanceRoute _fromState(GoRouterState state) =>
      const AppearanceRoute();

  @override
  String get location => GoRouteData.$location('/system/appearance');

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

mixin $ImportRoute on GoRouteData {
  static ImportRoute _fromState(GoRouterState state) => const ImportRoute();

  @override
  String get location => GoRouteData.$location('/system/import');

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

mixin $SystemDebugRoute on GoRouteData {
  static SystemDebugRoute _fromState(GoRouterState state) =>
      const SystemDebugRoute();

  @override
  String get location => GoRouteData.$location('/system/debug');

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

mixin $ActivityLogRoute on GoRouteData {
  static ActivityLogRoute _fromState(GoRouterState state) =>
      const ActivityLogRoute();

  @override
  String get location => GoRouteData.$location('/system/activity-log');

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

mixin $ActivityLogDetailRoute on GoRouteData {
  static ActivityLogDetailRoute _fromState(GoRouterState state) =>
      ActivityLogDetailRoute(id: state.pathParameters['id']!);

  ActivityLogDetailRoute get _self => this as ActivityLogDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/system/activity-log/${Uri.encodeComponent(_self.id)}',
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
