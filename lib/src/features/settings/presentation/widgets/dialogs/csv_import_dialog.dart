import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../../core/widgets/step_indicator.dart';
import '../../../../products/data/services/csv_import_service.dart';
import '../../controllers/csv_import_controller.dart';

/// Shows the CSV import dialog as a full-screen dialog.
void showCsvImportDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    fullScreen: true,
    builder: (context) => const ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CsvImportDialog(),
      ),
    ),
  );
}

/// Full-screen 4-step wizard for importing products from CSV.
///
/// Steps:
/// 0 - File Selection
/// 1 - Parse Summary
/// 2 - Review (select/deselect items)
/// 3 - Import Progress / Results
class CsvImportDialog extends HookConsumerWidget {
  const CsvImportDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = useState(0);
    final importState = ref.watch(csvImportControllerProvider);
    final controller = ref.read(csvImportControllerProvider.notifier);

    // Auto-advance when parsing completes
    useEffect(() {
      if (importState.phase == ImportPhase.staged && currentStep.value == 0) {
        currentStep.value = 1;
      }
      if (importState.phase == ImportPhase.completed &&
          currentStep.value == 3) {
        // Stay on step 3, show results
      }
      return null;
    }, [importState.phase]);

    return ConstrainedDialogContent(
      fullScreen: true,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: importState.phase == ImportPhase.importing
                      ? null
                      : () {
                          controller.reset();
                          context.pop();
                        },
                ),
                Expanded(
                  child: Text(
                    'Import Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (importState.phase != ImportPhase.importing)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () {
                        controller.reset();
                        context.pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StepIndicator(
              currentStep: currentStep.value,
              steps: const ['File', 'Summary', 'Review', 'Import'],
            ),
          ),
          const SizedBox(height: 16),

          // Step content
          Expanded(
            child: IndexedStack(
              index: currentStep.value,
              children: [
                // Step 0: File Selection
                _FileSelectionStep(
                  isLoading: importState.phase == ImportPhase.parsing,
                  onFilePicked: (content) {
                    controller.parseAndStage(content);
                  },
                ),

                // Step 1: Parse Summary
                _ParseSummaryStep(
                  parseResult: importState.parseResult,
                  onNext: () => currentStep.value = 2,
                  onBack: () {
                    controller.reset();
                    currentStep.value = 0;
                  },
                ),

                // Step 2: Review
                _ReviewStep(
                  parseResult: importState.parseResult,
                  onToggleEntry: controller.toggleEntry,
                  onSelectAll: controller.selectAll,
                  onImport: () {
                    currentStep.value = 3;
                    controller.executeImport();
                  },
                  onBack: () => currentStep.value = 1,
                ),

                // Step 3: Import Progress / Results
                _ImportProgressStep(
                  importState: importState,
                  onDone: () {
                    controller.reset();
                    context.pop();
                    showSuccessSnackBar(
                      context,
                      message: '${importState.importedCount} products imported',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 0: File Selection
// =============================================================================

class _FileSelectionStep extends StatelessWidget {
  const _FileSelectionStep({
    required this.isLoading,
    required this.onFilePicked,
  });

  final bool isLoading;
  final ValueChanged<String> onFilePicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.file_upload_outlined,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Select a CSV file to import',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'The CSV file should contain product data with columns for '
            'Name, Category, Price, and other product fields.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Expected columns: Name, Category, Description, Price, '
            'Track stock, Available for sale, In stock, Low stock',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              child: FilledButton.icon(
                onPressed: () => _pickFile(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Choose CSV File'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) return;

      final csvContent = utf8.decode(result.files.single.bytes!);
      onFilePicked(csvContent);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context,
            message: 'Failed to read file: $e', useRootMessenger: false);
      }
    }
  }
}

// =============================================================================
// Step 1: Parse Summary
// =============================================================================

class _ParseSummaryStep extends StatelessWidget {
  const _ParseSummaryStep({
    required this.parseResult,
    required this.onNext,
    required this.onBack,
  });

  final CsvParseResult? parseResult;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = parseResult;

    if (result == null) {
      return const Center(child: Text('No data'));
    }

    final noCategory =
        result.entries.where((e) => e.categoryName == null).length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Import Summary',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Stats cards
                _SummaryCard(
                  icon: Icons.inventory_2,
                  title: 'Products found',
                  value: '${result.entries.length}',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                if (result.skippedRows > 0) ...[
                  _SummaryCard(
                    icon: Icons.warning_amber,
                    title: 'Rows skipped (no name)',
                    value: '${result.skippedRows}',
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                ],

                const Divider(height: 32),

                // Category breakdown
                Text(
                  'Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                if (result.existingCategoryNames.isNotEmpty) ...[
                  _SummaryCard(
                    icon: Icons.check_circle_outline,
                    title: 'Existing categories (matched)',
                    value: '${result.existingCategoryNames.length}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: result.existingCategoryNames
                          .map((name) => Chip(
                                label: Text(name),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (result.newCategoryNames.isNotEmpty) ...[
                  _SummaryCard(
                    icon: Icons.add_circle_outline,
                    title: 'New categories (will be created)',
                    value: '${result.newCategoryNames.length}',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: result.newCategoryNames
                          .map((name) => Chip(
                                label: Text(name),
                                visualDensity: VisualDensity.compact,
                                backgroundColor:
                                    theme.colorScheme.tertiaryContainer,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (noCategory > 0) ...[
                  _SummaryCard(
                    icon: Icons.remove_circle_outline,
                    title: 'Products without category',
                    value: '$noCategory',
                    color: theme.colorScheme.outline,
                  ),
                ],

                // Warnings
                if (result.warnings.isNotEmpty) ...[
                  const Divider(height: 32),
                  Text(
                    'Warnings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.warnings.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 16, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(w)),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: result.entries.isEmpty ? null : onNext,
                child: const Text('Review Products'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: theme.textTheme.bodyMedium),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Step 2: Review
// =============================================================================

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.parseResult,
    required this.onToggleEntry,
    required this.onSelectAll,
    required this.onImport,
    required this.onBack,
  });

  final CsvParseResult? parseResult;
  final void Function(int index) onToggleEntry;
  final void Function(bool selected) onSelectAll;
  final VoidCallback onImport;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = parseResult;

    if (result == null) {
      return const Center(child: Text('No data'));
    }

    final selectedCount = result.selectedCount;
    final allSelected = selectedCount == result.entries.length;

    return Column(
      children: [
        // Header with select all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Checkbox(
                value: allSelected
                    ? true
                    : selectedCount == 0
                        ? false
                        : null,
                tristate: true,
                onChanged: (value) {
                  onSelectAll(value ?? false);
                },
              ),
              Text(
                '$selectedCount of ${result.entries.length} selected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Product list
        Expanded(
          child: ListView.builder(
            itemCount: result.entries.length,
            itemBuilder: (context, index) {
              final entry = result.entries[index];

              return CheckboxListTile(
                value: entry.isSelected,
                onChanged: (_) => onToggleEntry(index),
                title: Text(
                  entry.name,
                  style: TextStyle(
                    decoration:
                        entry.isSelected ? null : TextDecoration.lineThrough,
                    color: entry.isSelected ? null : theme.colorScheme.outline,
                  ),
                ),
                subtitle: Row(
                  children: [
                    if (entry.categoryName != null) ...[
                      Icon(Icons.folder_outlined,
                          size: 14, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        entry.categoryName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.attach_money,
                        size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 2),
                    Text(
                      entry.isVariablePrice
                          ? 'Variable'
                          : '${entry.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (entry.trackStock) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.inventory,
                          size: 14, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${entry.quantity?.toStringAsFixed(0) ?? 'N/A'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
                dense: true,
              );
            },
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: selectedCount == 0 ? null : onImport,
                icon: const Icon(Icons.file_download),
                label: Text('Import $selectedCount Products'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Step 3: Import Progress / Results
// =============================================================================

class _ImportProgressStep extends StatelessWidget {
  const _ImportProgressStep({
    required this.importState,
    required this.onDone,
  });

  final ImportState importState;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = importState.phase == ImportPhase.completed;
    final total = importState.totalToImport;
    final progress = total > 0
        ? (importState.importedCount + importState.failedCount) / total
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Progress icon
          Icon(
            isCompleted ? Icons.check_circle : Icons.file_download,
            size: 80,
            color: isCompleted ? Colors.green : theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),

          Text(
            isCompleted ? 'Import Complete' : 'Importing Products...',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Progress bar
          if (!isCompleted) ...[
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              '${importState.importedCount + importState.failedCount} of $total',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],

          if (isCompleted) ...[
            const SizedBox(height: 16),

            // Results
            _SummaryCard(
              icon: Icons.check_circle,
              title: 'Successfully imported',
              value: '${importState.importedCount}',
              color: Colors.green,
            ),

            if (importState.failedCount > 0) ...[
              const SizedBox(height: 8),
              _SummaryCard(
                icon: Icons.error,
                title: 'Failed',
                value: '${importState.failedCount}',
                color: theme.colorScheme.error,
              ),
            ],

            // Error details
            if (importState.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Errors',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              ...importState.errors.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline,
                          size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Center(
              child: FilledButton(
                onPressed: onDone,
                child: const Text('Done'),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
