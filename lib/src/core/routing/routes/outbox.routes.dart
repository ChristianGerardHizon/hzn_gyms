import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../sync/presentation/pages/outbox_page.dart';

part 'outbox.routes.g.dart';

/// Outbox queue page route.
@TypedGoRoute<OutboxRoute>(path: OutboxRoute.path)
class OutboxRoute extends GoRouteData with $OutboxRoute {
  const OutboxRoute();

  static const path = '/outbox';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OutboxPage();
  }
}
