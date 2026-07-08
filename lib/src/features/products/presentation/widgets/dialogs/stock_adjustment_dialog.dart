import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../domain/product.dart';
import '../../../domain/product_lot.dart';
import '../../controllers/stock_adjustment_controller.dart';

/// Dialog for adjusting stock quantity.
///
/// Supports both simple product adjustments and lot-specific adjustments.
/// Uses a delta-based approach with live preview of new quantity.
class StockAdjustmentDialog extends HookConsumerWidget {
  const StockAdjustmentDialog({super.key, this.product, this.lot})
    : assert(
        product != null || lot != null,
        'Either product or lot must be provided',
      );

  /// The product to adjust (for non-lot-tracked products).
  final Product? product;

  /// The lot to adjust (for lot-tracked products).
  final ProductLot? lot;

  /// Returns the current quantity being adjusted.
  num get _currentQuantity => lot?.quantity ?? product?.quantity ?? 0;

  /// Returns the display title for the dialog.
  String get _title => lot != null ? 'Adjust Lot Stock' : 'Adjust Stock';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);

    // UI state
    final isSaving = useState(false);
    final adjustmentType = useState<String>('add'); // 'add' or 'remove'
    final adjustmentAmount = useState<num>(0);

    // Calculate new quantity preview
    num newQuantity = adjustmentType.value == 'add'
        ? _currentQuantity + adjustmentAmount.value
        : _currentQuantity - adjustmentAmount.value;

    // Ensure non-negative
    if (newQuantity < 0) newQuantity = 0;

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);

        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;
      final type = adjustmentType.value;
      final amount = _parseNum(values['amount'] as String?);
      final reason = _nullIfEmpty(values['reason'] as String?);

      // Calculate final quantity
      num finalQuantity = type == 'add'
          ? _currentQuantity + amount
          : _currentQuantity - amount;

      // Validate non-negative
      if (finalQuantity < 0) {
        showFormErrorDialog(
          context,
          errors: ['Cannot reduce stock below zero'],
        );
        return;
      }

      isSaving.value = true;

      final controller = ref.read(stockAdjustmentControllerProvider.notifier);

      final adjustment = lot != null
          ? await controller.adjustLotStock(
              lot: lot!,
              newQuantity: finalQuantity,
              reason: reason,
            )
          : await controller.adjustProductStock(
              product: product!,
              newQuantity: finalQuantity,
              reason: reason,
            );

      if (adjustment == null) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to adjust stock. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(context, message: 'Stock adjusted successfully');
      }
    }

    return FormDialogScaffold(
      title: _title,
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      initialValue: const {'adjustmentType': 'add', 'amount': '', 'reason': ''},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current quantity display
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Stock',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _currentQuantity.toStringAsFixed(0),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lot != null)
                          Text(
                            'Lot: ${lot!.lotNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Adjustment type selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjustment Type',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'add',
                      label: Text('Add'),
                      icon: Icon(Icons.add),
                    ),
                    ButtonSegment(
                      value: 'remove',
                      label: Text('Remove'),
                      icon: Icon(Icons.remove),
                    ),
                  ],
                  selected: {adjustmentType.value},
                  onSelectionChanged: isSaving.value
                      ? null
                      : (values) {
                          adjustmentType.value = values.first;
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount (required)
          FormBuilderTextField(
            name: 'amount',
            decoration: const InputDecoration(
              labelText: 'Quantity *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
              helperText: 'Enter the quantity to add or remove',
            ),
            enabled: !isSaving.value,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Quantity is required'),
              FormBuilderValidators.numeric(errorText: 'Must be a number'),
              FormBuilderValidators.min(
                0,
                errorText: 'Must be a positive number',
              ),
            ]),
            onChanged: (value) {
              adjustmentAmount.value = _parseNum(value);
            },
          ),
          const SizedBox(height: 16),

          // New quantity preview
          Card(
            color: newQuantity < 0
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    newQuantity < _currentQuantity
                        ? Icons.trending_down
                        : newQuantity > _currentQuantity
                        ? Icons.trending_up
                        : Icons.trending_flat,
                    color: newQuantity < 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Stock',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: newQuantity < 0
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          newQuantity.toStringAsFixed(0),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: newQuantity < 0
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delta display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: adjustmentType.value == 'add'
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      adjustmentType.value == 'add'
                          ? '+${adjustmentAmount.value.toStringAsFixed(0)}'
                          : '-${adjustmentAmount.value.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: adjustmentType.value == 'add'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reason (optional)
          FormBuilderTextField(
            name: 'reason',
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
              helperText:
                  'e.g., Received shipment, Damaged items, Inventory count',
            ),
            enabled: !isSaving.value,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  String? _nullIfEmpty(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  num _parseNum(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return num.tryParse(text.trim()) ?? 0;
  }

  static const _fieldLabels = {
    'adjustmentType': 'Adjustment Type',
    'amount': 'Quantity',
    'reason': 'Reason',
  };
}

/// Shows the stock adjustment dialog for a product.
void showProductStockAdjustmentDialog(BuildContext context, Product product) {
  showConstrainedDialog(
    context: context,
    builder: (context) => StockAdjustmentDialog(product: product),
  );
}

/// Shows the stock adjustment dialog for a product lot.
void showLotStockAdjustmentDialog(BuildContext context, ProductLot lot) {
  showConstrainedDialog(
    context: context,
    builder: (context) => StockAdjustmentDialog(lot: lot),
  );
}
