import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../pos/presentation/services/thermal_print_service.dart';
import '../../data/repositories/printer_config_repository.dart';
import '../../domain/printer_config.dart';
import '../controllers/printer_configs_controller.dart';
import 'dialogs/printer_config_form_dialog.dart';

/// Detail panel for viewing/editing a printer configuration.
class PrinterConfigDetailPanel extends ConsumerWidget {
  const PrinterConfigDetailPanel({
    super.key,
    required this.printerId,
  });

  final String printerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Handle "new" ID for creating new printer
    if (printerId == 'new') {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Printer')),
        body: Center(
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
                'Add a new printer',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _showCreateSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Printer'),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Either<Failure, PrinterConfig>>(
      future: ref.read(printerConfigRepositoryProvider).fetchOne(printerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Printer not found',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final result = snapshot.data!;
        return result.fold(
          (failure) => ErrorState.fromError(failure, compact: true),
          (config) => _PrinterDetailContent(config: config),
        );
      },
    );
  }

  void _showCreateSheet(BuildContext context) {
    showPrinterConfigFormDialog(context);
  }
}

class _PrinterDetailContent extends HookConsumerWidget {
  const _PrinterDetailContent({required this.config});

  final PrinterConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPrinting = useState(false);

    Future<void> handleTestPrint() async {
      isPrinting.value = true;

      final printService = ref.read(thermalPrintServiceProvider.notifier);
      final result = await printService.printTestPage(config);

      isPrinting.value = false;

      if (!context.mounted) return;

      if (result is PrintSuccess) {
        showSuccessSnackBar(context, message: 'Test page sent to printer');
      } else if (result is PrintFailure) {
        showErrorSnackBar(context, message: result.message);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(config.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badges
            Row(
              children: [
                if (config.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Default',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: config.isEnabled
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    config.isEnabled ? 'Enabled' : 'Disabled',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: config.isEnabled
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Connection type
            _DetailRow(
              icon: config.connectionType.icon,
              label: 'Connection Type',
              value: config.connectionType.displayName,
            ),
            const SizedBox(height: 16),

            // Address
            _DetailRow(
              icon: config.isBluetooth ? Icons.bluetooth : Icons.language,
              label: config.isBluetooth ? 'MAC Address' : 'IP Address',
              value: config.address ?? 'Not configured',
            ),
            const SizedBox(height: 16),

            // Port (network only)
            if (config.isNetwork) ...[
              _DetailRow(
                icon: Icons.settings_ethernet,
                label: 'Port',
                value: config.port.toString(),
              ),
              const SizedBox(height: 16),
            ],

            // Paper width
            _DetailRow(
              icon: Icons.straighten,
              label: 'Paper Width',
              value: config.paperWidth.displayName,
            ),
            const SizedBox(height: 32),

            // Test Print button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isPrinting.value || !config.hasAddress
                    ? null
                    : handleTestPrint,
                icon: isPrinting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print),
                label: Text(isPrinting.value ? 'Printing...' : 'Test Print'),
              ),
            ),

            if (!config.hasAddress) ...[
              const SizedBox(height: 8),
              Text(
                'Configure the printer address to enable test printing.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Set as default button
            if (!config.isDefault && config.isEnabled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _setAsDefault(context, ref),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Set as Default'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showPrinterConfigFormDialog(context, config: config);
  }

  Future<void> _setAsDefault(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(printerConfigsControllerProvider.notifier)
        .setAsDefault(config.id);

    if (success && context.mounted) {
      showSuccessSnackBar(context, message: '${config.name} set as default');
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Printer'),
        content: Text('Are you sure you want to delete "${config.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(printerConfigsControllerProvider.notifier)
          .deleteConfig(config.id);

      if (success && context.mounted) {
        showSuccessSnackBar(context, message: 'Printer deleted');
        context.pop();
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
