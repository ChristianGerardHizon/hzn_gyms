import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../products/domain/product_category.dart';
import '../controllers/product_categories_controller.dart';

/// Detail panel for viewing/editing a product category in tablet layout.
class ProductCategoryDetailPanel extends HookConsumerWidget {
  const ProductCategoryDetailPanel({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  bool get isCreating => categoryId == 'new';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);

    // Find the category from the list
    final categoriesList = categoriesAsync.value;
    final category = categoriesList?.cast<ProductCategory?>().firstWhere(
      (c) => c?.id == categoryId,
      orElse: () => null,
    );

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    // UI state
    final isSaving = useState(false);
    final isDeleting = useState(false);

    // Reset form when category changes
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.patchValue({
          'name': category?.name ?? '',
          'parent': category?.parentId,
        });
      });
      return null;
    }, [category?.id]);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();
      if (!isValid) return;

      final values = formKey.currentState!.value;
      isSaving.value = true;

      final categoryData = ProductCategory(
        id: isCreating ? '' : categoryId,
        name: (values['name'] as String).trim(),
        parentId: values['parent'] as String?,
      );

      bool success;
      if (isCreating) {
        success = await ref
            .read(productCategoriesControllerProvider.notifier)
            .createCategory(categoryData);
      } else {
        success = await ref
            .read(productCategoriesControllerProvider.notifier)
            .updateCategory(categoryData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save category. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        showSuccessSnackBar(
          context,
          message: isCreating
              ? 'Category created successfully'
              : 'Category updated successfully',
        );

        if (isCreating) {
          const ProductCategoriesRoute().go(context);
        }
      }
    }

    Future<void> handleDelete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Category'),
          content:
              Text('Are you sure you want to delete "${category?.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isDeleting.value = true;
      final success = await ref
          .read(productCategoriesControllerProvider.notifier)
          .deleteCategory(categoryId);

      if (context.mounted) {
        isDeleting.value = false;
        if (success) {
          showSuccessSnackBar(
              context, message: 'Category deleted successfully');
          const ProductCategoriesRoute().go(context);
        } else {
          showFormErrorDialog(
            context,
            errors: ['Failed to delete category. Please try again.'],
          );
        }
      }
    }

    if (!isCreating && categoriesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isCreating && category == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Category not found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreating ? 'New Category' : 'Edit Category'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => const ProductCategoriesRoute().go(context),
        ),
        actions: [
          if (!isCreating)
            IconButton(
              icon: isDeleting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: isDeleting.value ? null : handleDelete,
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: isSaving.value ? null : handleSave,
            child: isSaving.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState.fromError(
          error,
          compact: true,
          onRetry: () => ref
              .read(productCategoriesControllerProvider.notifier)
              .refresh(),
        ),
        data: (categories) {
          // Filter out self and children to prevent circular reference
          final availableParents = categories.where((c) {
            if (isCreating) return true;
            // Can't be own parent
            if (c.id == categoryId) return false;
            // Can't select own children as parent
            if (c.parentId == categoryId) return false;
            return true;
          }).toList();

          return FormBuilder(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  FormBuilderTextField(
                    name: 'name',
                    initialValue: isCreating ? '' : category?.name,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'Enter category name',
                    ),
                    validator: FormBuilderValidators.required(),
                    textInputAction: TextInputAction.next,
                    autofocus: isCreating,
                  ),
                  const SizedBox(height: 16),

                  // Parent category dropdown
                  FormBuilderDropdown<String?>(
                    name: 'parent',
                    initialValue: isCreating ? null : category?.parentId,
                    decoration: const InputDecoration(
                      labelText: 'Parent Category',
                      hintText: 'Select parent (optional)',
                      // Keep label floated: null (root) is treated as empty otherwise.
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None (Root Category)'),
                      ),
                      ...availableParents.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
