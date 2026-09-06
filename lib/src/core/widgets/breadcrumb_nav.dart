import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n/strings.g.dart';
import '../routing/routes/branches.routes.dart';
import '../routing/routes/products.routes.dart';
import '../routing/routes/roles.routes.dart';
import '../routing/routes/sales.routes.dart';
import '../routing/routes/system.routes.dart';
import '../routing/routes/users.routes.dart';

/// A breadcrumb item representing a navigation point.
class BreadcrumbItem {
  const BreadcrumbItem({
    required this.label,
    required this.path,
    this.onTap,
  });

  final String label;
  final String path;
  final VoidCallback? onTap;
}

/// A breadcrumb navigation bar that generates items from the current GoRouter state.
///
/// Automatically parses the current route location and creates a clickable
/// breadcrumb trail for navigation.
class BreadcrumbNav extends StatelessWidget {
  const BreadcrumbNav({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final items = _buildBreadcrumbs(context, state);

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) _buildSeparator(context),
            _buildBreadcrumbItem(context, items[i],
                isLast: i == items.length - 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.chevron_right,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    BreadcrumbItem item, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);

    if (isLast) {
      // Current page - not clickable
      return Text(
        item.label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Clickable breadcrumb
    return InkWell(
      onTap: item.onTap ?? () => context.go(item.path),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          item.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// Builds breadcrumb items from the current router state.
  List<BreadcrumbItem> _buildBreadcrumbs(
      BuildContext context, GoRouterState state) {
    final t = Translations.of(context);
    final location = state.uri.path;
    final pathParameters = state.pathParameters;
    final items = <BreadcrumbItem>[];

    // Parse the path segments
    final segments = location.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      // On dashboard - show just Dashboard
      items.add(BreadcrumbItem(
        label: t.navigation.dashboard,
        path: '/',
      ));
      return items;
    }

    // Build breadcrumbs based on path segments
    String currentPath = '';
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      currentPath += '/$segment';

      final item = _getItemForSegment(
        context: context,
        segment: segment,
        fullPath: currentPath,
        segments: segments,
        index: i,
        pathParameters: pathParameters,
        translations: t,
      );

      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  BreadcrumbItem? _getItemForSegment({
    required BuildContext context,
    required String segment,
    required String fullPath,
    required List<String> segments,
    required int index,
    required Map<String, String> pathParameters,
    required Translations translations,
  }) {
    final t = translations;

    // Handle known routes
    switch (segment) {
      case 'products':
        return BreadcrumbItem(
          label: t.navigation.products,
          path: ProductsRoute.path,
          onTap: () => const ProductsRoute().go(context),
        );

      case 'cashier':
        return BreadcrumbItem(
          label: t.navigation.sales,
          path: SalesRoute.path,
          onTap: () => const SalesRoute().go(context),
        );

      case 'users':
        return BreadcrumbItem(
          label: t.navigation.users,
          path: UsersRoute.path,
          onTap: () => const UsersRoute().go(context),
        );

      case 'roles':
        return BreadcrumbItem(
          label: t.navigation.roles,
          path: RolesRoute.path,
          onTap: () => const RolesRoute().go(context),
        );

      case 'branches':
        return BreadcrumbItem(
          label: t.navigation.branches,
          path: BranchesRoute.path,
          onTap: () => const BranchesRoute().go(context),
        );

      case 'system':
        return BreadcrumbItem(
          label: t.navigation.system,
          path: SystemRoute.path,
          onTap: () => const SystemRoute().go(context),
        );

      default:
        return null;
    }
  }
}

/// Extension to easily add breadcrumbs to a page.
extension BreadcrumbNavExtension on Widget {
  Widget withBreadcrumbs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: BreadcrumbNav(),
        ),
        Expanded(child: this),
      ],
    );
  }
}
