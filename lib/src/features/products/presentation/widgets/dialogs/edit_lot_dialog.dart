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
import '../../../domain/product_lot.dart';
import '../../controllers/product_lots_controller.dart';

/// Dialog for editing an existing product lot.
class EditLotDialog extends HookConsumerWidget {
  const EditLotDialog({super.key, required this.lot});

  final ProductLot lot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: {
        'lotNumber': lot.lotNumber,
        'expiration': lot.expiration,
        'quantity': lot.quantity.toString(),
        'notes': lot.notes,
      },
    );

    // UI state
    final isSaving = useState(false);

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

      // Update lot
      final updatedLot = ProductLot(
        id: lot.id,
        productId: lot.productId,
        lotNumber: (values['lotNumber'] as String).trim(),
        quantity: _parseNum(values['quantity'] as String?) ?? 0,
        expiration: values['expiration'] as DateTime?,
        notes: _nullIfEmpty(values['notes'] as String?),
        isDeleted: lot.isDeleted,
        created: lot.created,
        updated: lot.updated,
      );

      final success = await ref
          .read(productLotsControllerProvider(lot.productId).notifier)
          .updateLot(updatedLot);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to update lot. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(context, message: 'Lot updated successfully');
      }
    }

    return FormDialogScaffold(
      title: 'Edit Lot',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      initialValue: {
        'lotNumber': lot.lotNumber,
        'quantity': lot.quantity.toString(),
        'expiration': lot.expiration,
        'notes': lot.notes ?? '',
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lot Number (required)
          FormBuilderTextField(
            name: 'lotNumber',
            decoration: const InputDecoration(
              labelText: 'Lot Number *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            enabled: !isSaving.value,
            textCapitalization: TextCapitalization.characters,
            validator: FormBuilderValidators.required(
              errorText: 'Lot number is required',
            ),
          ),
          const SizedBox(height: 16),

          // Quantity (required)
          FormBuilderTextField(
            name: 'quantity',
            decoration: const InputDecoration(
              labelText: 'Quantity *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.inventory),
            ),
            enabled: !isSaving.value,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Quantity is required'),
              FormBuilderValidators.numeric(errorText: 'Must be a number'),
            ]),
          ),
          const SizedBox(height: 16),

          // Expiration date
          FormBuilderDateTimePicker(
            name: 'expiration',
            decoration: const InputDecoration(
              labelText: 'Expiration Date',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            enabled: !isSaving.value,
            inputType: InputType.date,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
          ),
          const SizedBox(height: 16),

          // Notes
          FormBuilderTextField(
            name: 'notes',
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
            enabled: !isSaving.value,
            maxLines: 2,
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

  num? _parseNum(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return num.tryParse(text.trim());
  }

  static const _fieldLabels = {
    'lotNumber': 'Lot Number',
    'quantity': 'Quantity',
    'expiration': 'Expiration Date',
    'notes': 'Notes',
  };
}

/// Shows the edit lot dialog.
void showEditLotDialog(BuildContext context, ProductLot lot) {
  showConstrainedDialog(
    context: context,
    builder: (context) => EditLotDialog(lot: lot),
  );
}
