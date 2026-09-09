import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../quantity_units/domain/quantity_unit.dart';
import '../controllers/quantity_units_controller.dart';

/// Detail panel for viewing/editing a quantity unit in tablet layout.
class QuantityUnitDetailPanel extends HookConsumerWidget {
  const QuantityUnitDetailPanel({
    super.key,
    required this.unitId,
  });

  final String unitId;

  bool get isCreating => unitId == 'new';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(quantityUnitsControllerProvider);

    // Find the unit from the list
    final unitsList = unitsAsync.value;
    final unit = unitsList?.cast<QuantityUnit?>().firstWhere(
      (u) => u?.id == unitId,
      orElse: () => null,
    );

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    // UI state
    final isSaving = useState(false);
    final isDeleting = useState(false);

    // Reset form when unit changes
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.patchValue({
          'name': unit?.name ?? '',
          'shortSingular': unit?.shortSingular ?? '',
          'shortPlural': unit?.shortPlural ?? '',
          'longSingular': unit?.longSingular ?? '',
          'longPlural': unit?.longPlural ?? '',
        });
      });
      return null;
    }, [unit?.id]);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();
      if (!isValid) return;

      final values = formKey.currentState!.value;
      isSaving.value = true;

      final unitData = QuantityUnit(
        id: isCreating ? '' : unitId,
        name: (values['name'] as String).trim(),
        shortSingular: (values['shortSingular'] as String).trim(),
        shortPlural: (values['shortPlural'] as String).trim(),
        longSingular: (values['longSingular'] as String).trim(),
        longPlural: (values['longPlural'] as String).trim(),
      );

      bool success;
      if (isCreating) {
        success = await ref
            .read(quantityUnitsControllerProvider.notifier)
            .createUnit(unitData);
      } else {
        success = await ref
            .read(quantityUnitsControllerProvider.notifier)
            .updateUnit(unitData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save quantity unit. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        showSuccessSnackBar(
          context,
          message: isCreating
              ? 'Quantity unit created successfully'
              : 'Quantity unit updated successfully',
        );

        if (isCreating) {
          const QuantityUnitsRoute().goScoped(context);
        }
      }
    }

    Future<void> handleDelete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Quantity Unit'),
          content:
              Text('Are you sure you want to delete "${unit?.name}"?'),
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
          .read(quantityUnitsControllerProvider.notifier)
          .deleteUnit(unitId);

      if (context.mounted) {
        isDeleting.value = false;
        if (success) {
          showSuccessSnackBar(
              context, message: 'Quantity unit deleted successfully');
          const QuantityUnitsRoute().goScoped(context);
        } else {
          showFormErrorDialog(
            context,
            errors: ['Failed to delete quantity unit. Please try again.'],
          );
        }
      }
    }

    if (!isCreating && unitsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isCreating && unit == null) {
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
              'Quantity unit not found',
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
        title: Text(isCreating ? 'New Quantity Unit' : 'Edit Quantity Unit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => const QuantityUnitsRoute().goScoped(context),
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
          const SizedBox(width: 8),
          FilledButton(
            onPressed: isSaving.value ? null : handleSave,
            child: isSaving.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FormBuilder(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              FormBuilderTextField(
                name: 'name',
                initialValue: isCreating ? '' : unit?.name,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., kilograms',
                ),
                validator: FormBuilderValidators.required(),
                textInputAction: TextInputAction.next,
                autofocus: isCreating,
              ),
              const SizedBox(height: 16),

              // Short forms row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'shortSingular',
                      initialValue: isCreating ? '' : unit?.shortSingular,
                      decoration: const InputDecoration(
                        labelText: 'Short Singular *',
                        hintText: 'e.g., kg',
                      ),
                      validator: FormBuilderValidators.required(),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'shortPlural',
                      initialValue: isCreating ? '' : unit?.shortPlural,
                      decoration: const InputDecoration(
                        labelText: 'Short Plural *',
                        hintText: 'e.g., kg',
                      ),
                      validator: FormBuilderValidators.required(),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Long forms row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'longSingular',
                      initialValue: isCreating ? '' : unit?.longSingular,
                      decoration: const InputDecoration(
                        labelText: 'Long Singular *',
                        hintText: 'e.g., kilogram',
                      ),
                      validator: FormBuilderValidators.required(),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'longPlural',
                      initialValue: isCreating ? '' : unit?.longPlural,
                      decoration: const InputDecoration(
                        labelText: 'Long Plural *',
                        hintText: 'e.g., kilograms',
                      ),
                      validator: FormBuilderValidators.required(),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
