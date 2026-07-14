import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/check_in/presentation/pages/check_in_page.dart';
import '../../../features/check_in/presentation/pages/check_in_records_page.dart';

part 'check_in.routes.g.dart';

/// Check-in page route.
@TypedGoRoute<CheckInRoute>(path: CheckInRoute.path)
class CheckInRoute extends GoRouteData with $CheckInRoute {
  const CheckInRoute();

  static const path = '/check-in';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CheckInPage();
  }
}

/// Check-in records (history by date) route.
@TypedGoRoute<CheckInRecordsRoute>(path: CheckInRecordsRoute.path)
class CheckInRecordsRoute extends GoRouteData with $CheckInRecordsRoute {
  const CheckInRecordsRoute();

  static const path = '/check-in-records';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CheckInRecordsPage();
  }
}
