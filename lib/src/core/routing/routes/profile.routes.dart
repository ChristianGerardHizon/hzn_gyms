import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/profile/presentation/pages/profile_page.dart';

part 'profile.routes.g.dart';

/// Profile page for the signed-in user's own account.
@TypedGoRoute<ProfileRoute>(path: ProfileRoute.path)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  static const path = '/profile';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}
