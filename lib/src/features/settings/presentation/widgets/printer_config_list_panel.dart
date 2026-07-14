import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/printer_config.dart';
import '../controllers/printer_configs_controller.dart';
import 'dialogs/printer_config_form_dialog.dart';

/// List panel for printer configurations (tablet master-detail layout).
class PrinterConfigListPanel extends ConsumerWidget {
  const PrinterConfigListPanel({
    super.key,
    this.selectedId,
    this.onPrinterSelected,
  });

  final String? selectedId;
  final ValueChanged<PrinterConfig>? onPrinterSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final printersAsync = ref.watch(printerConfigsControllerProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Printers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateSheet(context),
                tooltip: 'Add Printer',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: printersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState.fromError(
              error,
              compact: true,
              onRetry: () =>
                  ref.invalidate(printerConfigsControllerProvider),
            ),
            data: (printers) {
              if (printers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_outlined,
                        size: 48,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No printers configured',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showCreateSheet(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Printer'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref
                    .read(printerConfigsControllerProvider.notifier)
                    .refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: printers.length,
                  itemBuilder: (context, index) {
                    final printer = printers[index];
                    final isSelected = printer.id == selectedId;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            printer.connectionType.icon,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                printer.name,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : null,
                                ),
                              ),
                            ),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        trailing: printer.isEnabled
                            ? null
                            : Icon(
                                Icons.block,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                        onTap: () {
                          if (onPrinterSelected != null) {
                            onPrinterSelected!(printer);
                          }
                          PrinterDetailRoute(id: printer.id).go(context);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateSheet(BuildContext context) {
    showPrinterConfigFormDialog(context);
  }
}
