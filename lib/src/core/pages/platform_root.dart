import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../i18n/strings.g.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/platform.routes.dart';
import '../utils/breakpoints.dart';
import '../widgets/organization_switcher.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart'
    show allBranchesSlug;

/// Shell for platform super-admin routes (`/platform/*`).
class PlatformRoot extends ConsumerWidget {
  const PlatformRoot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final isSetup = location.contains('/setup');
    final isMobile = Breakpoints.isMobile(context);

    if (isSetup) {
      return child;
    }

    final selectedIndex = location.startsWith(PlatformUsersRoute.path)
        ? 2
        : location.startsWith(PlatformOrganizationsRoute.path)
        ? 1
        : 0;

    void onNavTap(int index) {
      switch (index) {
        case 0:
          const PlatformDashboardRoute().go(context);
        case 1:
          const PlatformOrganizationsRoute().go(context);
        case 2:
          const PlatformUsersRoute().go(context);
      }
    }

    Future<void> enterTenant() async {
      final org = ref.read(currentOrganizationControllerProvider).value;
      if (org == null || org.id.isEmpty) return;
      await ref
          .read(currentOrganizationControllerProvider.notifier)
          .switchOrganization(org.id);
      if (context.mounted) {
        context.go('/${org.slug}/$allBranchesSlug${DashboardRoute.path}');
      }
    }

    final orgSelected =
        ref.watch(currentOrganizationControllerProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.organizations.platformTitle),
        actions: [
          const OrganizationSwitcher(compact: true),
          if (orgSelected)
            TextButton.icon(
              onPressed: enterTenant,
              icon: const Icon(Icons.login),
              label: Text(t.organizations.enterTenant),
            ),
        ],
      ),
      body: isMobile
          ? child
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onNavTap,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: Text(t.organizations.platformDashboard),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.business_outlined),
                      selectedIcon: const Icon(Icons.business),
                      label: Text(t.organizations.title),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.people_outline),
                      selectedIcon: const Icon(Icons.people),
                      label: Text(t.organizations.platformUsersTitle),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onNavTap,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: t.organizations.platformDashboard,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.business_outlined),
                  selectedIcon: const Icon(Icons.business),
                  label: t.organizations.title,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: t.organizations.platformUsersTitle,
                ),
              ],
            )
          : null,
    );
  }
}
