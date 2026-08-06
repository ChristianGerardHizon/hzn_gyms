import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_status.dart';
import '../providers/pos_product_stock_provider.dart';
import '../../domain/out_of_stock_warn.dart';

/// Shows a warning when [productName] is out of stock.
///
/// Returns null if cancelled; otherwise whether to continue and optionally
/// snooze the warning until tomorrow.
Future<OutOfStockContinueResult?> showOutOfStockContinueDialog(
  BuildContext context, {
  required String productName,
}) {
  return showDialog<OutOfStockContinueResult>(
    context: context,
    builder: (context) => _OutOfStockContinueDialog(productName: productName),
  );
}

class _OutOfStockContinueDialog extends HookWidget {
  const _OutOfStockContinueDialog({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snoozeUntilTomorrow = useState(false);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.error,
        size: 32,
      ),
      title: const Text('Out of stock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$productName is already out of stock. Do you want to continue adding it to the cart?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: snoozeUntilTomorrow.value,
            onChanged: (value) =>
                snoozeUntilTomorrow.value = value ?? false,
            title: const Text("Don't warn again until tomorrow"),
            subtitle: const Text(
              'Skip this warning for this product for the rest of today',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            OutOfStockContinueResult(
              continueSale: true,
              snoozeUntilTomorrow: snoozeUntilTomorrow.value,
            ),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

/// Returns `true` when the cashier may proceed to add [product].
///
/// Shows [showOutOfStockContinueDialog] when stock is out (unless snoozed).
Future<bool> confirmOutOfStockSaleIfNeeded({
  required BuildContext context,
  required WidgetRef ref,
  required Product product,
  ProductStatus? stockStatus,
}) async {
  if (!product.trackStock) return true;

  var status = stockStatus;
  if (status == null) {
    status = await ref.read(posProductStockProvider(product).future);
  }
  if (status != ProductStatus.outOfStock) return true;

  final prefs = ref.read(appDatabaseProvider).appPreferencesDao;
  final snoozeRaw = await prefs.getValue(outOfStockWarnSnoozeKey(product.id));
  if (isOutOfStockWarnSnoozeActive(snoozeRaw)) return true;

  if (!context.mounted) return false;

  final result = await showOutOfStockContinueDialog(
    context,
    productName: product.name,
  );
  if (result == null || !result.continueSale) return false;

  if (result.snoozeUntilTomorrow) {
    final until = startOfNextLocalDay().toUtc().toIso8601String();
    await prefs.setValue(outOfStockWarnSnoozeKey(product.id), until);
  }

  return true;
}
