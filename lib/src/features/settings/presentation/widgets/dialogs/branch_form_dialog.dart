import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/utils/slugify.dart';
import '../../../../../core/widgets/branch_code_pill.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../domain/branch.dart';
import '../../../domain/branch_color_preset.dart';
import '../../controllers/branches_controller.dart';

/// Dialog for creating or editing a branch.
class BranchFormDialog extends HookConsumerWidget {
  const BranchFormDialog({super.key, this.branch});

  final Branch? branch;

  bool get isEditing => branch != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': branch!.name,
              'code': branch!.code,
              'slug': branch!.slug,
              'color': branch!.color,
              'address': branch!.address,
              'contactNumber': branch!.contactNumber,
              'operatingHours': branch!.operatingHours ?? '',
              'cutOffTime': branch!.cutOffTime ?? '',
            }
          : null,
    );

    // UI state
    final isSaving = useState(false);
    final selectedColorId = useState<String?>(branch?.color);
    final previewCode = useState(branch?.code ?? '');
    final previewName = useState(branch?.name ?? '');
    // Once the user edits the slug directly, stop auto-deriving it from name.
    final slugManuallyEdited = useState(isEditing);

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

      final branchData = Branch(
        id: branch?.id ?? '',
        name: (values['name'] as String).trim(),
        code: (values['code'] as String).trim().toUpperCase(),
        slug: (values['slug'] as String).trim().toLowerCase(),
        address: (values['address'] as String?)?.trim() ?? '',
        contactNumber: (values['contactNumber'] as String?)?.trim() ?? '',
        operatingHours: _nullIfEmpty(values['operatingHours'] as String?),
        cutOffTime: _nullIfEmpty(values['cutOffTime'] as String?),
        color: _nullIfEmpty(values['color'] as String?),
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(branchesControllerProvider.notifier)
            .updateBranch(branchData);
      } else {
        success = await ref
            .read(branchesControllerProvider.notifier)
            .createBranch(branchData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save branch. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Branch updated successfully'
              : 'Branch created successfully',
        );
      }
    }

    final theme = Theme.of(context);
    final previewLabel = previewCode.value.trim().isNotEmpty
        ? previewCode.value.trim().toUpperCase()
        : 'CODE';
    final previewAccent = BranchColorPreset.resolveColor(
      selectedColorId.value,
      fallback: theme.colorScheme.tertiary,
    );

    return FormDialogScaffold(
      title: isEditing ? 'Edit Branch' : 'New Branch',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderTextField(
            name: 'name',
            initialValue: branch?.name,
            decoration: const InputDecoration(
              labelText: 'Name *',
              hintText: 'Enter branch name (e.g. Bacolod Branch)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
            ),
            enabled: !isSaving.value,
            validator: branchNameValidator(),
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              previewName.value = value ?? '';
              if (!slugManuallyEdited.value) {
                formKey.currentState?.fields['slug']?.didChange(
                  slugify(value ?? ''),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'code',
            initialValue: branch?.code,
            decoration: const InputDecoration(
              labelText: 'Code *',
              hintText: 'e.g. BCD, TAL',
              helperText:
                  'Short unique code shown on branch pills in lists and '
                  'dashboards (max 5 letters/numbers)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              counterText: '',
            ),
            enabled: !isSaving.value,
            maxLength: 5,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              _UpperCaseTextFormatter(),
            ],
            validator: branchCodeValidator(),
            textInputAction: TextInputAction.next,
            onChanged: (value) => previewCode.value = value ?? '',
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'slug',
            initialValue: branch?.slug,
            decoration: const InputDecoration(
              labelText: 'URL slug *',
              hintText: 'e.g. downtown',
              helperText:
                  'Used in web links, e.g. /org/downtown/... Must be unique '
                  'within the organization; "all" is reserved.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            enabled: !isSaving.value,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
            ],
            validator: branchSlugValidator(),
            textInputAction: TextInputAction.next,
            onChanged: (_) => slugManuallyEdited.value = true,
          ),
          const SizedBox(height: 16),
          FormBuilderField<String?>(
            name: 'color',
            initialValue: branch?.color,
            builder: (field) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Pill color',
                  helperText: 'Accent used on branch pills across the app',
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final preset in BranchColorPreset.presets)
                          _ColorSwatch(
                            color: preset.color,
                            selected: field.value == preset.id,
                            enabled: !isSaving.value,
                            tooltip: preset.label,
                            onTap: () {
                              final next =
                                  field.value == preset.id ? null : preset.id;
                              field.didChange(next);
                              selectedColorId.value = next;
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BranchCodePill(
                      label: previewLabel,
                      tooltip: previewName.value.trim().isEmpty
                          ? null
                          : previewName.value.trim(),
                      color: previewAccent,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'address',
            initialValue: branch?.address,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'Enter address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            enabled: !isSaving.value,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'contactNumber',
            initialValue: branch?.contactNumber,
            decoration: const InputDecoration(
              labelText: 'Contact Number',
              hintText: 'Enter contact number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            enabled: !isSaving.value,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'operatingHours',
            initialValue: branch?.operatingHours,
            decoration: const InputDecoration(
              labelText: 'Operating Hours',
              hintText: 'e.g., Mon-Sat 8:00 AM - 5:00 PM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule),
            ),
            enabled: !isSaving.value,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'cutOffTime',
            initialValue: branch?.cutOffTime,
            decoration: const InputDecoration(
              labelText: 'Cut-off Time',
              hintText: 'e.g., 4:30 PM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer_off),
            ),
            enabled: !isSaving.value,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  static const _fieldLabels = {
    'name': 'Name',
    'code': 'Code',
    'slug': 'URL slug',
    'color': 'Pill color',
    'address': 'Address',
    'contactNumber': 'Contact Number',
    'operatingHours': 'Operating Hours',
    'cutOffTime': 'Cut-off Time',
  };

  String? _nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.enabled,
    required this.tooltip,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final bool enabled;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? theme.colorScheme.onSurface
                  : color.withValues(alpha: 0.4),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: ThemeData.estimateBrightnessForColor(color) ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                )
              : null,
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Required: non-empty branch name.
FormFieldValidator<String> branchNameValidator() {
  return FormBuilderValidators.required(errorText: 'Name is required');
}

/// Required: 1–5 alphanumeric characters (used on branch pills).
FormFieldValidator<String> branchCodeValidator() {
  return FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: 'Code is required'),
    FormBuilderValidators.minLength(1, errorText: 'Code is required'),
    FormBuilderValidators.maxLength(
      5,
      errorText: 'Code must be at most 5 characters',
    ),
    FormBuilderValidators.match(
      RegExp(r'^[A-Za-z0-9]+$'),
      errorText: 'Letters and numbers only',
    ),
  ]);
}

/// Required: URL-safe slug, unique per organization. "all" is reserved for
/// the "all branches" route segment.
FormFieldValidator<String> branchSlugValidator() {
  return FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: 'URL slug is required'),
    FormBuilderValidators.match(
      RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'),
      errorText: 'Lowercase letters, numbers and hyphens only',
    ),
    (value) {
      if (value?.trim().toLowerCase() == 'all') {
        return '"all" is reserved and cannot be used as a branch slug';
      }
      return null;
    },
  ]);
}

/// Shows the branch form dialog.
void showBranchFormDialog(BuildContext context, {Branch? branch}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => BranchFormDialog(branch: branch),
  );
}
