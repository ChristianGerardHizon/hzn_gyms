import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/dashboard/presentation/pages/todays_transactions_page.dart';

part 'todays_transactions.routes.g.dart';

/// Today's transactions list route (View All from dashboard).
@TypedGoRoute<TodaysTransactionsRoute>(path: TodaysTransactionsRoute.path)
class TodaysTransactionsRoute extends GoRouteData with $TodaysTransactionsRoute {
  const TodaysTransactionsRoute();

  static const path = '/todays-transactions';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TodaysTransactionsPage();
  }
}
