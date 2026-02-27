import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/check_in/presentation/pages/check_in_page.dart';

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
