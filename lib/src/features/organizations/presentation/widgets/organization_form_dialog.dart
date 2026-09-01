import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/organization.dart';
import '../controllers/organizations_controller.dart';

/// Dialog for creating or editing an organization.
class OrganizationFormDialog extends HookConsumerWidget {
  const OrganizationFormDialog({super.key, this.organization});

  final Organization? organization;

  bool get isEditing => organization != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': organization!.name,
              'slug': organization!.slug,
              'displayName': organization!.displayName ?? '',
              'seedColor': organization!.seedColor ?? '',
              'splashBackgroundColor':
                  organization!.splashBackgroundColor ?? '',
            }
          : null,
    );
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

      final orgData = Organization(
        id: organization?.id ?? '',
        name: (values['name'] as String).trim(),
        slug: (values['slug'] as String).trim().toLowerCase(),
        displayName: _nullIfEmpty(values['displayName'] as String?),
        seedColor: _nullIfEmpty(values['seedColor'] as String?),
        splashBackgroundColor:
            _nullIfEmpty(values['splashBackgroundColor'] as String?),
      );

      final success = isEditing
          ? await ref
              .read(organizationsControllerProvider.notifier)
              .updateOrganization(orgData)
          : await ref
              .read(organizationsControllerProvider.notifier)
              .createOrganization(orgData);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save organization. Please try again.'],
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
              ? 'Organization updated successfully'
              : 'Organization created successfully',
        );
      }
    }

    return FormDialogScaffold(
      title: isEditing ? 'Edit Organization' : 'Create Organization',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderTextField(
            name: 'name',
            initialValue: organization?.name,
            decoration: const InputDecoration(
              labelText: 'Name *',
              hintText: 'Kylie Gym',
              border: OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.maxLength(100),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'slug',
            initialValue: organization?.slug,
            decoration: const InputDecoration(
              labelText: 'Slug *',
              hintText: 'kyliegym',
              helperText: 'Used for subdomain (e.g. slug.hzngyms.com)',
              border: OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.match(
                RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'),
                errorText: 'Lowercase letters, numbers, and hyphens only',
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'displayName',
            initialValue: organization?.displayName,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'Shown in app title/branding',
              border: OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'seedColor',
            initialValue: organization?.seedColor,
            decoration: const InputDecoration(
              labelText: 'Seed Color',
              hintText: '#1E88E5',
              border: OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(trimmed)) {
                return 'Use hex format like #1E88E5';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'splashBackgroundColor',
            initialValue: organization?.splashBackgroundColor,
            decoration: const InputDecoration(
              labelText: 'Splash Background Color',
              hintText: '#FFFFFF',
              border: OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(trimmed)) {
                return 'Use hex format like #FFFFFF';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

String? _nullIfEmpty(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

const _fieldLabels = {
  'name': 'Name',
  'slug': 'Slug',
  'displayName': 'Display Name',
  'seedColor': 'Seed Color',
  'splashBackgroundColor': 'Splash Background Color',
};
