import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/products/domain/product_category.dart';
import '../../../features/settings/presentation/controllers/product_categories_controller.dart';
import '../../../features/settings/presentation/pages/system_shell.dart';
import '../../../features/settings/presentation/widgets/dialogs/product_category_form_dialog.dart';
import '../../../features/settings/presentation/widgets/product_category_detail_panel.dart';
import '../../../features/settings/presentation/widgets/printer_config_detail_panel.dart';
import '../../../features/settings/presentation/widgets/theme_settings_panel.dart';
import '../../../features/settings/presentation/controllers/printer_configs_controller.dart';
import '../../../features/settings/presentation/widgets/dialogs/printer_config_form_dialog.dart';
import '../../../features/pos/presentation/pages/cashier_groups_settings_page.dart';
import '../../../features/pos/presentation/widgets/cashier_group_detail_panel.dart';
import '../../../features/settings/presentation/widgets/import_landing_panel.dart';
import '../../../features/settings/presentation/widgets/quantity_unit_detail_panel.dart';
import '../../../features/settings/presentation/controllers/quantity_units_controller.dart';
import '../../../features/settings/presentation/widgets/dialogs/quantity_unit_form_dialog.dart';
import '../../../features/quantity_units/domain/quantity_unit.dart';
import '../../permissions/current_user_permissions.dart';
import '../../utils/breakpoints.dart';
import '../../widgets/state/error_state.dart';

part 'system.routes.g.dart';

/// System shell route for 3-panel layout.
///
/// On tablet: Shows nav rail + list + detail side-by-side
/// On mobile: Shows landing page, then list, then detail
@TypedShellRoute<SystemShellRoute>(
  routes: [
    TypedGoRoute<SystemRoute>(
      path: SystemRoute.path,
      routes: [
        // Product categories with detail
        TypedGoRoute<ProductCategoriesRoute>(
          path: 'product-categories',
          routes: [
            TypedGoRoute<ProductCategoryDetailRoute>(path: ':id'),
          ],
        ),
        // Quantity units with detail
        TypedGoRoute<QuantityUnitsRoute>(
          path: 'quantity-units',
          routes: [
            TypedGoRoute<QuantityUnitDetailRoute>(path: ':id'),
          ],
        ),
        // Printer settings with detail
        TypedGoRoute<PrinterSettingsRoute>(
          path: 'printers',
          routes: [
            TypedGoRoute<PrinterDetailRoute>(path: ':id'),
          ],
        ),
        // Cashier layout groups with detail
        TypedGoRoute<CashierGroupsRoute>(
          path: 'cashier-groups',
          routes: [
            TypedGoRoute<CashierGroupDetailRoute>(path: ':id'),
          ],
        ),
        // Appearance/theme settings
        TypedGoRoute<AppearanceRoute>(path: 'appearance'),
        // Import products from CSV
        TypedGoRoute<ImportRoute>(path: 'import'),
      ],
    ),
  ],
)
class SystemShellRoute extends ShellRouteData {
  const SystemShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return SystemShell(child: navigator);
  }
}

/// System root route.
///
/// On tablet: Redirects to /system/product-categories (3-panel layout)
/// On mobile: Shows landing page with Categories/Printers/Appearance/Import options
class SystemRoute extends GoRouteData with $SystemRoute {
  const SystemRoute();

  static const path = '/system';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final perms = ProviderScope.containerOf(context)
        .read(currentUserPermissionsProvider)
        .value;
    // Wait until the role loads — defaulting to empty would send staff to the
    // tablet admin tab (product-categories) before settings.view is known.
    if (perms == null) return null;

    // Non-admin with settings access lands on Appearance only.
    if (!perms.canManageSystem && perms.canViewSettings) {
      if (state.uri.path == path ||
          (!state.uri.path.startsWith('$path/appearance') &&
              state.uri.path.startsWith(path))) {
        return '$path/appearance';
      }
      return null;
    }

    // Only redirect on tablet - mobile shows landing page
    if (Breakpoints.isTabletOrLarger(context) && state.uri.path == path) {
      return '$path/product-categories';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // Mobile: Show landing page with options
    return const _MobileSystemLandingPage();
  }
}

/// Product categories management route.
class ProductCategoriesRoute extends GoRouteData with $ProductCategoriesRoute {
  const ProductCategoriesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show categories list
    return const _MobileProductCategoriesListPage();
  }
}

/// Product category detail route.
class ProductCategoryDetailRoute extends GoRouteData
    with $ProductCategoryDetailRoute {
  const ProductCategoryDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProductCategoryDetailPanel(categoryId: id);
  }
}

/// Quantity units management route.
class QuantityUnitsRoute extends GoRouteData with $QuantityUnitsRoute {
  const QuantityUnitsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show quantity units list
    return const _MobileQuantityUnitsListPage();
  }
}

/// Quantity unit detail route.
class QuantityUnitDetailRoute extends GoRouteData
    with $QuantityUnitDetailRoute {
  const QuantityUnitDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return QuantityUnitDetailPanel(unitId: id);
  }
}

/// Printer settings management route.
class PrinterSettingsRoute extends GoRouteData with $PrinterSettingsRoute {
  const PrinterSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show printers list
    return const _MobilePrinterListPage();
  }
}

/// Printer detail route.
class PrinterDetailRoute extends GoRouteData with $PrinterDetailRoute {
  const PrinterDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PrinterConfigDetailPanel(printerId: id);
  }
}

/// Appearance/theme settings route.
class AppearanceRoute extends GoRouteData with $AppearanceRoute {
  const AppearanceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ThemeSettingsPanel();
  }
}

/// Import products from CSV route.
class ImportRoute extends GoRouteData with $ImportRoute {
  const ImportRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show import landing page
    return const _MobileImportPage();
  }
}

/// Cashier groups management route.
class CashierGroupsRoute extends GoRouteData with $CashierGroupsRoute {
  const CashierGroupsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show cashier groups list
    return const CashierGroupsSettingsPage();
  }
}

/// Cashier group detail route.
class CashierGroupDetailRoute extends GoRouteData
    with $CashierGroupDetailRoute {
  const CashierGroupDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CashierGroupDetailPanel(groupId: id);
  }
}

// ============================================================================
// Mobile Pages
// ============================================================================

/// Mobile landing page for system settings with option cards.
class _MobileSystemLandingPage extends ConsumerWidget {
  const _MobileSystemLandingPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final perms =
        ref.watch(currentUserPermissionsProvider).value ??
            CurrentUserPermissions.empty;
    final isAdmin = perms.canManageSystem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isAdmin) ...[
            _SystemOptionCard(
              icon: Icons.inventory_2,
              title: 'Product Categories',
              description: 'Manage product category hierarchy',
              color: theme.colorScheme.secondary,
              onTap: () => const ProductCategoriesRoute().go(context),
            ),
            const SizedBox(height: 16),
            _SystemOptionCard(
              icon: Icons.straighten,
              title: 'Quantity Units',
              description: 'Manage units of measurement',
              color: Colors.cyan,
              onTap: () => const QuantityUnitsRoute().go(context),
            ),
            const SizedBox(height: 16),
            _SystemOptionCard(
              icon: Icons.print,
              title: 'Printers',
              description: 'Configure thermal receipt printers',
              color: Colors.orange,
              onTap: () => const PrinterSettingsRoute().go(context),
            ),
            const SizedBox(height: 16),
            _SystemOptionCard(
              icon: Icons.point_of_sale,
              title: 'Cashier Layout',
              description: 'Customize cashier page groups',
              color: Colors.teal,
              onTap: () => const CashierGroupsRoute().go(context),
            ),
            const SizedBox(height: 16),
          ],
          if (perms.canViewSettings) ...[
            _SystemOptionCard(
              icon: Icons.palette,
              title: 'Appearance',
              description: 'Customize app theme and colors',
              color: Colors.purple,
              onTap: () => const AppearanceRoute().go(context),
            ),
            const SizedBox(height: 16),
          ],
          if (isAdmin)
            _SystemOptionCard(
              icon: Icons.file_upload,
              title: 'Import',
              description: 'Import products from CSV file',
              color: Colors.indigo,
              onTap: () => const ImportRoute().go(context),
            ),
        ],
      ),
    );
  }
}

/// Card widget for system option selection.
class _SystemOptionCard extends StatelessWidget {
  const _SystemOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile product categories list page.
class _MobileProductCategoriesListPage extends ConsumerWidget {
  const _MobileProductCategoriesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);
    final controller = ref.read(productCategoriesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_category_fab',
        onPressed: () => showProductCategoryFormDialog(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () => controller.refresh(),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a category',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          // Build hierarchical display
          final rootCategories =
              categories.where((c) => !c.hasParent).toList();
          final childCategories = categories.where((c) => c.hasParent).toList();

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              itemCount: rootCategories.length,
              itemBuilder: (context, index) {
                final category = rootCategories[index];
                final children = childCategories
                    .where((c) => c.parentId == category.id)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MobileCategoryListTile(
                      category: category,
                      isChild: false,
                      onTap: () => ProductCategoryDetailRoute(id: category.id)
                          .push(context),
                    ),
                    ...children.map((child) => Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: _MobileCategoryListTile(
                            category: child,
                            isChild: true,
                            onTap: () =>
                                ProductCategoryDetailRoute(id: child.id)
                                    .push(context),
                          ),
                        )),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MobileCategoryListTile extends StatelessWidget {
  const _MobileCategoryListTile({
    required this.category,
    required this.isChild,
    required this.onTap,
  });

  final ProductCategory category;
  final bool isChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isChild
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        child: Icon(
          isChild ? Icons.subdirectory_arrow_right : Icons.inventory_2_outlined,
          color: isChild
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(category.name),
      subtitle: category.hasParent && category.parentName != null
          ? Text('Parent: ${category.parentName}')
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Mobile printer list page.
class _MobilePrinterListPage extends ConsumerWidget {
  const _MobilePrinterListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final printersAsync = ref.watch(printerConfigsControllerProvider);
    final controller = ref.read(printerConfigsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printers'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'printer_fab',
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
      body: printersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () => controller.refresh(),
        ),
        data: (printers) {
          if (printers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.print_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No printers configured',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a printer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      printer.connectionType.icon,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(printer.name)),
                      if (printer.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Default',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${printer.connectionType.displayName} • ${printer.paperWidth.displayName}',
                  ),
                  trailing: printer.isEnabled
                      ? const Icon(Icons.chevron_right)
                      : Icon(Icons.block, color: theme.colorScheme.error),
                  onTap: () => PrinterDetailRoute(id: printer.id).push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showPrinterConfigFormDialog(context);
  }
}

/// Mobile import page.
class _MobileImportPage extends StatelessWidget {
  const _MobileImportPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Products'),
      ),
      body: const ImportLandingPanel(),
    );
  }
}

/// Mobile quantity units list page.
class _MobileQuantityUnitsListPage extends ConsumerWidget {
  const _MobileQuantityUnitsListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(quantityUnitsControllerProvider);
    final controller = ref.read(quantityUnitsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantity Units'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'quantity_unit_fab',
        onPressed: () => showQuantityUnitFormDialog(context),
        tooltip: 'Add Unit',
        child: const Icon(Icons.add),
      ),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () => controller.refresh(),
        ),
        data: (units) {
          if (units.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quantity units yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a unit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return _MobileQuantityUnitListTile(
                  unit: unit,
                  onTap: () =>
                      QuantityUnitDetailRoute(id: unit.id).push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MobileQuantityUnitListTile extends StatelessWidget {
  const _MobileQuantityUnitListTile({
    required this.unit,
    required this.onTap,
  });

  final QuantityUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.straighten,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(unit.name),
      subtitle: Text(unit.shortPlural),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
