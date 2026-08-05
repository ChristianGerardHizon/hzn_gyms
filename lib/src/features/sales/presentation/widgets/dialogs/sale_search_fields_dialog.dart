import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../domain/sale_status_filter.dart';
import '../../controllers/sale_search_controller.dart';

/// Dialog for selecting which fields to include in sale search.
class SaleSearchFieldsDialog extends ConsumerWidget {
  const SaleSearchFieldsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final t = Translations.of(context);
    final selectedFields = ref.watch(saleSearchFieldsProvider);
    final selectedStatuses = ref.watch(saleStatusFiltersProvider);

    return DialogCloseHandler(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      t.fields.searchFields,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () {
                        ref.read(saleSearchFieldsProvider.notifier).reset();
                        ref.read(saleStatusFiltersProvider.notifier).reset();
                      },
                      child: Text(t.common.reset),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: Text(t.common.done),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    Text(
                      t.fields.searchFieldsHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field checkboxes
                    ...saleSearchableFields.map((field) {
                      final isSelected = selectedFields.contains(field);
                      final isLastSelected =
                          isSelected && selectedFields.length == 1;

                      return CheckboxListTile(
                        key: ValueKey('$field-$isSelected'),
                        value: isSelected,
                        onChanged: isLastSelected
                            ? null // Can't deselect the last field
                            : (_) => ref
                                .read(saleSearchFieldsProvider.notifier)
                                .toggleField(field),
                        title: Text(_getFieldLabel(field, t)),
                        subtitle: isLastSelected
                            ? Text(
                                t.fields.atLeastOneRequired,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),

                    const SizedBox(height: 24),
                    Text(
                      t.fields.statusFilters,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.fields.statusFiltersHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...saleStatusFilterOptions.map((status) {
                      final isSelected = selectedStatuses.contains(status);
                      final isLastSelected =
                          isSelected && selectedStatuses.length == 1;

                      return SwitchListTile(
                        key: ValueKey('status-$status-$isSelected'),
                        value: isSelected,
                        onChanged: isLastSelected
                            ? null
                            : (_) => ref
                                .read(saleStatusFiltersProvider.notifier)
                                .toggleStatus(status),
                        title: Text(_getStatusLabel(status, t)),
                        subtitle: isLastSelected
                            ? Text(
                                t.fields.atLeastOneRequired,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldLabel(String field, Translations t) {
    switch (field) {
      case 'receiptNumber':
        return t.fields.receiptNumber;
      case 'descriptor':
        return t.fields.descriptor;
      case 'customerName':
        return t.fields.customerName;
      case 'paymentRef':
        return t.fields.paymentRef;
      case 'notes':
        return t.fields.notes;
      default:
        return field;
    }
  }

  String _getStatusLabel(String status, Translations t) {
    switch (status) {
      case 'paid':
        return t.fields.statusPaid;
      case 'voided':
        return t.fields.statusVoided;
      case 'awaitingPayment':
        return t.fields.statusAwaitingPayment;
      default:
        return status;
    }
  }
}

/// Shows the sale search fields selection dialog.
void showSaleSearchFieldsDialog(BuildContext context) {
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      insetPadding: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: SaleSearchFieldsDialog(),
    ),
  );
}
