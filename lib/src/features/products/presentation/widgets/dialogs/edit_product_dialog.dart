import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../../core/widgets/form/form_section_header.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../../settings/presentation/controllers/branches_controller.dart';
import '../../../domain/product.dart';
import '../../controllers/paginated_products_controller.dart';
import '../../controllers/product_categories_provider.dart';
import '../../controllers/product_provider.dart';

/// Shows the edit product dialog.
void showEditProductDialog(BuildContext context, String productId) {
  showConstrainedDialog(
    context: context,
    builder: (context) => EditProductDialog(productId: productId),
  );
}

/// Dialog for editing an existing product.
class EditProductDialog extends HookConsumerWidget {
  const EditProductDialog({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch product
    final productAsync = ref.watch(productProvider(productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return ConstrainedDialogContent(
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
                          'Edit Product',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        const Text('Product not found'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _EditProductForm(product: product);
      },
      loading: () => ConstrainedDialogContent(
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
                      'Edit Product',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
      error: (error, _) => ConstrainedDialogContent(
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
                      'Edit Product',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ErrorState.fromError(
                error,
                compact: true,
                onRetry: () => ref.invalidate(productProvider(productId)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProductForm extends HookConsumerWidget {
  const _EditProductForm({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: {
        'name': product.name,
        'description': product.description ?? '',
        'category': product.categoryId,
        'branch': product.branch,
        'price': product.isVariablePrice ? '' : product.price.toString(),
        'quantity': product.quantity?.toString() ?? '',
        'stockThreshold': product.stockThreshold?.toString() ?? '',
        'expiration': product.expiration,
        'forSale': product.forSale,
        'trackByLot': product.trackByLot,
        'requireStock': product.requireStock,
      },
    );

    // UI state
    final isSaving = useState(false);
    final trackByLot = useState(product.trackByLot);

    // Derive initial section states from existing product data
    // Price section is enabled if the product has a non-variable price set
    final priceEnabled = useState(!product.isVariablePrice);
    // Stock section is enabled if the product has trackStock enabled
    final stockEnabled = useState(product.trackStock);

    // Watch categories and branches
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);

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

      isSaving.value = true;

      // Create updated product
      final updatedProduct = Product(
        id: product.id,
        name: (values['name'] as String).trim(),
        description: _nullIfEmpty(values['description'] as String?),
        categoryId: values['category'] as String?,
        price: priceEnabled.value
            ? (_parseNum(values['price'] as String?) ?? 0)
            : 0,
        quantity: stockEnabled.value
            ? _parseNum(values['quantity'] as String?)
            : null,
        stockThreshold: stockEnabled.value
            ? _parseNum(values['stockThreshold'] as String?)
            : null,
        forSale: values['forSale'] as bool? ?? true,
        trackStock: stockEnabled.value,
        trackByLot: stockEnabled.value
            ? (values['trackByLot'] as bool? ?? false)
            : false,
        requireStock: stockEnabled.value
            ? (values['requireStock'] as bool? ?? false)
            : false,
        expiration: stockEnabled.value && !trackByLot.value
            ? values['expiration'] as DateTime?
            : null,
        image: product.image,
        branch: values['branch'] as String?,
        isDeleted: product.isDeleted,
        created: product.created,
        updated: product.updated,
      );

      final success = await ref
          .read(paginatedProductsControllerProvider.notifier)
          .updateProduct(updatedProduct);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to update product. Please try again.'],
          );
        }
        return;
      }

      // Invalidate the single product provider to refresh
      ref.invalidate(productProvider(product.id));

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(context, message: 'Product updated successfully');
      }
    }

    return FormDialogScaffold(
      title: 'Edit Product',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      initialValue: {
        'name': product.name,
        'description': product.description ?? '',
        'category': product.categoryId,
        'branch': product.branch,
        'price': product.isVariablePrice ? '' : product.price.toString(),
        'quantity': product.quantity?.toString() ?? '',
        'stockThreshold': product.stockThreshold?.toString() ?? '',
        'expiration': product.expiration,
        'forSale': product.forSale,
        'trackByLot': product.trackByLot,
        'requireStock': product.requireStock,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // === GENERAL ===
          const FormSectionHeader(
            title: 'General',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),

          // Name (required)
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Product Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label_outline),
            ),
            enabled: !isSaving.value,
            textCapitalization: TextCapitalization.words,
            validator: FormBuilderValidators.required(
              errorText: 'Product name is required',
            ),
          ),
          const SizedBox(height: 16),

          // Description
          FormBuilderTextField(
            name: 'description',
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
            ),
            enabled: !isSaving.value,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Category dropdown
          categoriesAsync.when(
            data: (categories) => FormBuilderDropdown<String>(
              name: 'category',
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              enabled: !isSaving.value,
              items: categories.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
            ),
            loading: () => const TextField(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                suffixIcon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              enabled: false,
            ),
            error: (_, __) => const TextField(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                errorText: 'Failed to load',
              ),
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // Branch dropdown
          branchesAsync.when(
            data: (branches) => FormBuilderDropdown<String>(
              name: 'branch',
              decoration: const InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              enabled: !isSaving.value,
              items: branches.map((branch) {
                return DropdownMenuItem(
                  value: branch.id,
                  child: Text(branch.name),
                );
              }).toList(),
            ),
            loading: () => const TextField(
              decoration: InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                suffixIcon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              enabled: false,
            ),
            error: (_, __) => const TextField(
              decoration: InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                errorText: 'Failed to load',
              ),
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // For Sale switch (always visible)
          FormBuilderSwitch(
            name: 'forSale',
            decoration: const InputDecoration(border: InputBorder.none),
            title: const Text('For Sale'),
            enabled: !isSaving.value,
          ),
          const SizedBox(height: 24),

          // === PRICE SECTION ===
          _SectionToggle(
            title: 'Price',
            icon: Icons.attach_money,
            enabled: priceEnabled.value,
            onToggle: (value) => priceEnabled.value = value,
            isSaving: isSaving.value,
          ),
          if (priceEnabled.value) ...[
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'price',
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '\u20b1 ',
                helperText: 'Leave empty for variable price (set at POS)',
              ),
              enabled: !isSaving.value,
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.numeric(
                errorText: 'Must be a number',
              ),
            ),
          ],
          const SizedBox(height: 24),

          // === STOCK SECTION ===
          _SectionToggle(
            title: 'Stock',
            icon: Icons.inventory_2_outlined,
            enabled: stockEnabled.value,
            onToggle: (value) {
              stockEnabled.value = value;
              if (!value) {
                trackByLot.value = false;
              }
            },
            isSaving: isSaving.value,
          ),
          if (stockEnabled.value) ...[
            const SizedBox(height: 16),

            // Quantity (hidden when tracking by lot)
            if (!trackByLot.value) ...[
              FormBuilderTextField(
                name: 'quantity',
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                enabled: !isSaving.value,
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.numeric(
                  errorText: 'Must be a number',
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stock threshold
            FormBuilderTextField(
              name: 'stockThreshold',
              decoration: const InputDecoration(
                labelText: 'Low Stock Threshold',
                border: OutlineInputBorder(),
                helperText: 'Alert when quantity falls below this value',
              ),
              enabled: !isSaving.value,
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.numeric(
                errorText: 'Must be a number',
              ),
            ),
            const SizedBox(height: 16),

            // Expiration date (hidden when tracking by lot)
            if (!trackByLot.value) ...[
              FormBuilderDateTimePicker(
                name: 'expiration',
                decoration: const InputDecoration(
                  labelText: 'Expiration Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                enabled: !isSaving.value,
                inputType: InputType.date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              ),
              const SizedBox(height: 16),
            ],

            // Track by Lot switch
            FormBuilderSwitch(
              name: 'trackByLot',
              decoration: const InputDecoration(border: InputBorder.none),
              title: const Text('Track by Lot'),
              subtitle: const Text('Track inventory by lot numbers'),
              enabled: !isSaving.value,
              onChanged: (value) => trackByLot.value = value ?? false,
            ),

            // Require Stock switch
            FormBuilderSwitch(
              name: 'requireStock',
              decoration: const InputDecoration(border: InputBorder.none),
              title: const Text('Require Stock'),
              subtitle: const Text('Block sales when out of stock'),
              enabled: !isSaving.value,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String? _nullIfEmpty(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  num? _parseNum(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return num.tryParse(text.trim());
  }

  static const _fieldLabels = {
    'name': 'Product Name',
    'description': 'Description',
    'category': 'Category',
    'branch': 'Branch',
    'price': 'Price',
    'quantity': 'Quantity',
    'stockThreshold': 'Stock Threshold',
    'expiration': 'Expiration Date',
    'forSale': 'For Sale',
    'trackByLot': 'Track by Lot',
    'requireStock': 'Require Stock',
  };
}

/// A toggle header for enabling/disabling a form section.
class _SectionToggle extends StatelessWidget {
  const _SectionToggle({
    required this.title,
    required this.icon,
    required this.enabled,
    required this.onToggle,
    required this.isSaving,
  });

  final String title;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        value: enabled,
        onChanged: isSaving ? null : onToggle,
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
