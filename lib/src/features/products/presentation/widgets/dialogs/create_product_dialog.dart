import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../settings/domain/branch.dart';
import '../../../domain/product_category.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/routing/routes/products.routes.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../../settings/presentation/controllers/branches_controller.dart';
import '../../../domain/product.dart';
import '../../controllers/paginated_products_controller.dart';
import '../../controllers/product_categories_provider.dart';

/// Dialog for creating a new product.
class CreateProductDialog extends HookConsumerWidget {
  const CreateProductDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);

    // UI state
    final isSaving = useState(false);
    final trackByLot = useState(false);
    final priceEnabled = useState(true);
    final stockEnabled = useState(false);

    // Watch categories and branches
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final userBranchId = ref.watch(currentBranchIdProvider);

    Future<void> handleSave(BuildContext dialogContext) async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);

        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(dialogContext, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;

      isSaving.value = true;

      // Create product
      final product = Product(
        id: '',
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
        branch: values['branch'] as String?,
      );

      final createdProduct = await ref
          .read(paginatedProductsControllerProvider.notifier)
          .createProduct(product);

      if (createdProduct == null) {
        if (dialogContext.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            dialogContext,
            errors: ['Failed to create product. Please try again.'],
          );
        }
        return;
      }

      if (dialogContext.mounted) {
        isSaving.value = false;
        Navigator.of(dialogContext).pop();

        showSuccessSnackBar(dialogContext,
            message: 'Product created successfully');

        // Navigate to product detail
        ProductDetailRoute(id: createdProduct.id).go(dialogContext);
      }
    }

    // Find the user's branch for initial value
    Branch? initialBranch;
    if (branchesAsync.hasValue && userBranchId != null) {
      final branches = branchesAsync.value!;
      initialBranch = branches.cast<Branch?>().firstWhere(
            (b) => b?.id == userBranchId,
            orElse: () => branches.isNotEmpty ? branches.first : null,
          );
    }

    return FormDialogScaffold(
      title: 'Create Product',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: handleSave,
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
          AsyncFormDropdown<ProductCategory>(
            name: 'category',
            label: 'Category',
            asyncData: categoriesAsync,
            displayString: (category) => category.name,
            enabled: !isSaving.value,
            prefixIcon: Icons.category_outlined,
            valueTransformer: (category) => category?.id,
          ),
          const SizedBox(height: 16),

          // Branch dropdown
          AsyncFormDropdown<Branch>(
            name: 'branch',
            label: 'Branch',
            asyncData: branchesAsync,
            displayString: (branch) => branch.name,
            initialValue: initialBranch,
            enabled: !isSaving.value,
            prefixIcon: Icons.business,
            valueTransformer: (branch) => branch?.id,
            subtitleBuilder: (branch) =>
                branch.address.isNotEmpty ? branch.address : null,
          ),
          const SizedBox(height: 16),

          // For Sale switch (always visible)
          FormBuilderSwitch(
            name: 'forSale',
            initialValue: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
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
            CurrencyInputField(
              name: 'price',
              label: 'Price',
              required: false,
              enabled: !isSaving.value,
              helperText: 'Leave empty for variable price (set at POS)',
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
              NumericInputField(
                name: 'quantity',
                label: 'Quantity',
                enabled: !isSaving.value,
              ),
              const SizedBox(height: 16),
            ],

            // Stock threshold
            NumericInputField(
              name: 'stockThreshold',
              label: 'Low Stock Threshold',
              enabled: !isSaving.value,
              helperText: 'Alert when quantity falls below this value',
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
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              ),
              const SizedBox(height: 16),
            ],

            // Track by Lot switch
            FormBuilderSwitch(
              name: 'trackByLot',
              initialValue: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              title: const Text('Track by Lot'),
              subtitle: const Text('Track inventory by lot numbers'),
              enabled: !isSaving.value,
              onChanged: (value) => trackByLot.value = value ?? false,
            ),

            // Require Stock switch
            FormBuilderSwitch(
              name: 'requireStock',
              initialValue: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              title: const Text('Require Stock'),
              subtitle: const Text('Block sales when out of stock'),
              enabled: !isSaving.value,
            ),
          ],
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

/// Shows the create product dialog.
void showCreateProductDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    builder: (context) => const CreateProductDialog(),
  );
}
