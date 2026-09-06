import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';

/// Step 3 — create the first branch for the tenant.
class OrganizationSetupBranchForm extends HookConsumerWidget {
  const OrganizationSetupBranchForm({
    super.key,
    required this.organizationId,
    required this.onCreated,
  });

  final String organizationId;
  final ValueChanged<String> onCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      isSaving.value = true;
      final values = formKey.currentState!.value;
      final branch = Branch(
        id: '',
        name: (values['name'] as String).trim(),
        code: (values['code'] as String).trim().toUpperCase(),
        address: (values['address'] as String?)?.trim() ?? '',
        contactNumber: (values['contactNumber'] as String?)?.trim() ?? '',
        organization: organizationId,
      );
      final created = await ref
          .read(branchesControllerProvider.notifier)
          .createBranch(branch);
      isSaving.value = false;
      if (!created) {
        if (context.mounted) {
          showFormErrorDialog(
            context,
            errors: [t.organizations.setupBranchFailed],
          );
        }
        return;
      }
      final branches = ref.read(branchesControllerProvider).value ?? [];
      if (branches.isNotEmpty) {
        onCreated(branches.first.id);
      }
    }

    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: InputDecoration(
              labelText: '${t.organizations.setupBranchName} *',
              border: const OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'code',
            decoration: InputDecoration(
              labelText: '${t.organizations.setupBranchCode} *',
              border: const OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.maxLength(5),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isSaving.value ? null : handleSave,
            child: isSaving.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(t.organizations.setupCreateBranch),
          ),
        ],
      ),
    );
  }
}
