import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../activity_log/presentation/pages/activity_log_detail_page.dart';
import '../../../activity_log/presentation/pages/activity_logs_page.dart';
import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../pos/presentation/controllers/pos_groups_controller.dart';
import '../../../pos/presentation/widgets/cashier_group_detail_panel.dart';
import '../../../products/domain/product_category.dart';
import '../controllers/product_categories_controller.dart';
import '../controllers/printer_configs_controller.dart';
import '../controllers/quantity_units_controller.dart';
import 'empty_system_state.dart';
import 'dialogs/quantity_unit_form_dialog.dart';
import 'dialogs/printer_config_form_dialog.dart';
import 'dialogs/product_category_form_dialog.dart';
import 'import_landing_panel.dart';
import 'system_debug_panel.dart';
import 'system_nav_panel.dart';
import 'camera_settings_panel.dart';
import 'theme_settings_panel.dart';

/// Three-panel tablet layout for system settings.
///
/// Panel 1 (72px): Navigation rail for Categories/Printers/Appearance/Camera/Import selection
/// Panel 2 (320px): List panel based on current mode
/// Panel 3 (expanded): Detail panel from router or empty state
class TabletSystemLayout extends ConsumerWidget {
  const TabletSystemLayout({
    super.key,
    required this.detailChild,
  });

  /// The detail panel content from the router.
  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = GoRouterState.of(context);
    final path = routerState.uri.path;
    final selectedId = routerState.pathParameters['id'];

    // Determine current mode from path
    final SystemMode currentMode;
    if (path.contains('/quantity-units')) {
      currentMode = SystemMode.quantityUnits;
    } else if (path.contains('/printers')) {
      currentMode = SystemMode.printers;
    } else if (path.contains('/cashier-groups')) {
      currentMode = SystemMode.cashierGroups;
    } else if (path.contains('/appearance')) {
      currentMode = SystemMode.appearance;
    } else if (path.contains('/camera')) {
      currentMode = SystemMode.camera;
    } else if (path.contains('/import')) {
      currentMode = SystemMode.import;
    } else if (path.contains('/debug')) {
      currentMode = SystemMode.debug;
    } else if (path.contains('/activity-log')) {
      currentMode = SystemMode.activityLog;
    } else {
      currentMode = SystemMode.productCategories;
    }

    return Row(
      children: [
        // Panel 1: Navigation
        SystemNavPanel(
          currentMode: currentMode,
          onModeChanged: (mode) {
            switch (mode) {
              case SystemMode.productCategories:
                const ProductCategoriesRoute().goScoped(context);
              case SystemMode.quantityUnits:
                const QuantityUnitsRoute().goScoped(context);
              case SystemMode.printers:
                const PrinterSettingsRoute().goScoped(context);
              case SystemMode.cashierGroups:
                const CashierGroupsRoute().goScoped(context);
              case SystemMode.appearance:
                const AppearanceRoute().goScoped(context);
              case SystemMode.camera:
                const CameraRoute().goScoped(context);
              case SystemMode.import:
                const ImportRoute().goScoped(context);
              case SystemMode.debug:
                const SystemDebugRoute().goScoped(context);
              case SystemMode.activityLog:
                const ActivityLogRoute().goScoped(context);
            }
          },
        ),
        const VerticalDivider(width: 1),

        // Panel 2: List (or full panel for appearance/camera/import/debug)
        if (currentMode == SystemMode.appearance) ...[
          // Appearance mode: Show settings panel directly (no list/detail split)
          const Expanded(child: ThemeSettingsPanel()),
        ] else if (currentMode == SystemMode.camera) ...[
          const Expanded(child: CameraSettingsPanel()),
        ] else if (currentMode == SystemMode.import) ...[
          // Import mode: Show landing panel directly (no list/detail split)
          const Expanded(child: ImportLandingPanel()),
        ] else if (currentMode == SystemMode.debug) ...[
          const Expanded(child: SystemDebugPanel()),
        ] else if (currentMode == SystemMode.activityLog) ...[
          SizedBox(
            width: 360,
            child: ActivityLogsPage(
              selectedId: selectedId,
              onSelected: (id) => ActivityLogDetailRoute(id: id).goScoped(context),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedId != null
                ? ActivityLogDetailPage(logId: selectedId)
                : const EmptySystemState(mode: SystemMode.activityLog),
          ),
        ] else if (currentMode == SystemMode.cashierGroups) ...[
          // Cashier groups mode: List + detail split
          SizedBox(
            width: 320,
            child: _CashierGroupListWrapper(selectedId: selectedId),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedId != null
                ? CashierGroupDetailPanel(groupId: selectedId)
                : EmptySystemState(mode: currentMode),
          ),
        ] else ...[
          SizedBox(
            width: 320,
            child: switch (currentMode) {
              SystemMode.productCategories =>
                _ProductCategoryListWrapper(selectedId: selectedId),
              SystemMode.quantityUnits =>
                _QuantityUnitListWrapper(selectedId: selectedId),
              SystemMode.printers =>
                _PrinterListWrapper(selectedId: selectedId),
              SystemMode.appearance =>
                const SizedBox.shrink(), // Handled above
              SystemMode.camera =>
                const SizedBox.shrink(), // Handled above
              SystemMode.import =>
                const SizedBox.shrink(), // Handled above
              SystemMode.debug =>
                const SizedBox.shrink(), // Handled above
              SystemMode.activityLog =>
                const SizedBox.shrink(), // Handled above
              SystemMode.cashierGroups =>
                const SizedBox.shrink(), // Handled above
            },
          ),
          const VerticalDivider(width: 1),

          // Panel 3: Detail
          Expanded(
            child: selectedId != null
                ? detailChild
                : EmptySystemState(mode: currentMode),
          ),
        ],
      ],
    );
  }
}

/// Wrapper for ProductCategoryListPanel with system-specific navigation.
class _ProductCategoryListWrapper extends ConsumerWidget {
  const _ProductCategoryListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);
    final controller = ref.read(productCategoriesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_category_fab',
        onPressed: () => showProductCategoryFormDialog(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
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
                    _CategoryListTile(
                      category: category,
                      isSelected: category.id == selectedId,
                      isChild: false,
                      onTap: () =>
                          ProductCategoryDetailRoute(id: category.id).goScoped(context),
                    ),
                    ...children.map((child) => Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: _CategoryListTile(
                            category: child,
                            isSelected: child.id == selectedId,
                            isChild: true,
                            onTap: () =>
                                ProductCategoryDetailRoute(id: child.id)
                                    .go(context),
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

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.isSelected,
    required this.isChild,
    required this.onTap,
  });

  final ProductCategory category;
  final bool isSelected;
  final bool isChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : isChild
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.primaryContainer,
        child: Icon(
          isChild ? Icons.subdirectory_arrow_right : Icons.inventory_2_outlined,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : isChild
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

/// Wrapper for PrinterListPanel with system-specific navigation.
class _PrinterListWrapper extends ConsumerWidget {
  const _PrinterListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final printersAsync = ref.watch(printerConfigsControllerProvider);
    final controller = ref.read(printerConfigsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printers'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'printer_fab',
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
      body: printersAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
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
                final isSelected = printer.id == selectedId;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primaryContainer,
                    child: Icon(
                      printer.connectionType.icon,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
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
                  onTap: () => PrinterDetailRoute(id: printer.id).goScoped(context),
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

/// Wrapper for QuantityUnitListPanel with system-specific navigation.
class _QuantityUnitListWrapper extends ConsumerWidget {
  const _QuantityUnitListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(quantityUnitsControllerProvider);
    final controller = ref.read(quantityUnitsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantity Units'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'quantity_unit_fab',
        onPressed: () => showQuantityUnitFormDialog(context),
        tooltip: 'Add Unit',
        child: const Icon(Icons.add),
      ),
      body: unitsAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
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
                final isSelected = unit.id == selectedId;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.straighten,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(unit.name),
                  subtitle: Text(unit.shortPlural),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => QuantityUnitDetailRoute(id: unit.id).goScoped(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper for cashier group list in tablet layout.
class _CashierGroupListWrapper extends ConsumerWidget {
  const _CashierGroupListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(posGroupsControllerProvider);
    final controller = ref.read(posGroupsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Layout'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cashier_group_list_fab',
        onPressed: () => _showCreateDialog(context),
        tooltip: 'Add Group',
        child: const Icon(Icons.add),
      ),
      body: groupsAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
          onRetry: () => controller.refresh(),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No groups yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a group',
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
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final isSelected = group.id == selectedId;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.dashboard_customize,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(group.name),
                  subtitle: Text(
                    '${group.items.length} item${group.items.length == 1 ? '' : 's'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      CashierGroupDetailRoute(id: group.id).goScoped(context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    // Import is at the top of the file
    showDialog(
      context: context,
      builder: (context) => const _CreateGroupDialog(),
    );
  }
}

class _CreateGroupDialog extends HookConsumerWidget {
  const _CreateGroupDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final isSaving = useState(false);

    Future<void> handleSave() async {
      final name = nameController.text.trim();
      if (name.isEmpty) return;

      isSaving.value = true;
      final error = await ref
          .read(posGroupsControllerProvider.notifier)
          .createGroup(name);
      isSaving.value = false;

      if (error == null && context.mounted) {
        Navigator.of(context).pop();
      } else if (context.mounted) {
        showErrorSnackBar(context, message: error ?? 'Unknown error');
      }
    }

    return AlertDialog(
      title: const Text('New Group'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Group Name *',
          hintText: 'e.g., Detergents, Wash Services',
        ),
        autofocus: true,
        onSubmitted: (_) => handleSave(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isSaving.value ? null : handleSave,
          child: isSaving.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
