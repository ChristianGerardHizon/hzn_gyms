import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../controllers/product_search_controller.dart';

/// Dialog for selecting which fields to include in product search.
class ProductSearchFieldsDialog extends ConsumerWidget {
  const ProductSearchFieldsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final selectedFields = ref.watch(productSearchFieldsProvider);

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
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
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(productSearchFieldsProvider.notifier).reset();
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
                  const SizedBox(height: 16),

                  Text(
                    t.fields.searchFieldsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field checkboxes
                  ...productSearchableFields.map((field) {
                    final isSelected = selectedFields.contains(field);
                    final isLastSelected =
                        isSelected && selectedFields.length == 1;

                    return CheckboxListTile(
                      key: ValueKey('$field-$isSelected'),
                      value: isSelected,
                      onChanged: isLastSelected
                          ? null // Can't deselect the last field
                          : (_) => ref
                              .read(productSearchFieldsProvider.notifier)
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
      case 'name':
        return t.fields.name;
      case 'description':
        return t.fields.description;
      case 'category':
        return t.fields.category;
      default:
        return field;
    }
  }
}

/// Shows the product search fields selection dialog.
void showProductSearchFieldsDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => const ProductSearchFieldsDialog(),
  );
}
