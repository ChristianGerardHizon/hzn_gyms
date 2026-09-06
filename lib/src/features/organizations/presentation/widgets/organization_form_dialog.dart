import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/platform.routes.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/organization.dart';
import '../../domain/organization_logo_draft.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organizations_controller.dart';
import 'organization_logo_picker.dart';
import 'organization_seed_color_field.dart';

/// Dialog for creating or editing an organization.
class OrganizationFormDialog extends HookConsumerWidget {
  const OrganizationFormDialog({super.key, this.organization});

  final Organization? organization;

  bool get isEditing => organization != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': organization!.name,
              'slug': organization!.slug,
              'displayName': organization!.displayName ?? '',
              'seedColor': normalizeHexColor(organization!.seedColor) ?? '',
              'splashBackgroundColor':
                  organization!.splashBackgroundColor ?? '',
            }
          : null,
    );
    final isSaving = useState(false);
    final logoDraft = useState<OrganizationLogoDraft?>(null);
    final fieldLabels = {
      'name': t.organizations.name,
      'slug': t.organizations.slug,
      'displayName': t.organizations.displayName,
      'seedColor': t.organizations.seedColor,
      'splashBackgroundColor': t.organizations.splashBackgroundColor,
    };

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();
      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, fieldLabels);
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
        seedColor: normalizeHexColor(values['seedColor'] as String?),
        splashBackgroundColor:
            _nullIfEmpty(values['splashBackgroundColor'] as String?),
      );

      if (isEditing) {
        final success = await ref
            .read(organizationsControllerProvider.notifier)
            .updateOrganization(
              orgData.copyWith(id: organization!.id),
              logoDraft: logoDraft.value,
            );
        if (!success) {
          if (context.mounted) {
            isSaving.value = false;
            showFormErrorDialog(
              context,
              errors: [t.organizations.saveFailed],
            );
          }
          return;
        }
      } else {
        final created = await ref
            .read(organizationsControllerProvider.notifier)
            .createOrganization(orgData, logoDraft: logoDraft.value);
        if (created == null) {
          if (context.mounted) {
            isSaving.value = false;
            showFormErrorDialog(
              context,
              errors: [t.organizations.saveFailed],
            );
          }
          return;
        }

        if (context.mounted) {
          isSaving.value = false;
          context.pop(true);
          showSuccessSnackBar(
            context,
            message: t.organizations.createSuccess,
          );
          await ref
              .read(currentOrganizationControllerProvider.notifier)
              .switchOrganization(created.id);
          if (context.mounted) {
            OrganizationSetupRoute(orgId: created.id).go(context);
          }
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop(true);
        showSuccessSnackBar(
          context,
          message: t.organizations.updateSuccess,
        );
      }
    }

    return FormDialogScaffold(
      title: isEditing ? t.organizations.edit : t.organizations.create,
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrganizationLogoPicker(
            existingLogoUrl: organization?.logoTransparentUrl,
            enabled: !isSaving.value,
            onChanged: (draft) => logoDraft.value = draft,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'name',
            initialValue: organization?.name,
            decoration: InputDecoration(
              labelText: '${t.organizations.name} *',
              hintText: 'Kylie Gym',
              border: const OutlineInputBorder(),
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
            decoration: InputDecoration(
              labelText: '${t.organizations.slug} *',
              hintText: 'kyliegym',
              helperText: t.organizations.slugHelper,
              border: const OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.match(
                RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'),
                errorText: t.organizations.slugValidationError,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'displayName',
            initialValue: organization?.displayName,
            decoration: InputDecoration(
              labelText: t.organizations.displayName,
              hintText: t.organizations.displayNameHint,
              border: const OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
          ),
          const SizedBox(height: 16),
          OrganizationSeedColorField(
            name: 'seedColor',
            initialValue: organization?.seedColor,
            enabled: !isSaving.value,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'splashBackgroundColor',
            initialValue: organization?.splashBackgroundColor,
            decoration: InputDecoration(
              labelText: t.organizations.splashBackgroundColor,
              hintText: '#FFFFFF',
              border: const OutlineInputBorder(),
            ),
            enabled: !isSaving.value,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(trimmed)) {
                return t.organizations.splashColorValidationError;
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

/// Shows the create/edit organization dialog.
Future<bool?> showOrganizationFormDialog(
  BuildContext context, {
  Organization? organization,
}) {
  return showConstrainedDialog<bool>(
    context: context,
    builder: (context) => OrganizationFormDialog(organization: organization),
  );
}
