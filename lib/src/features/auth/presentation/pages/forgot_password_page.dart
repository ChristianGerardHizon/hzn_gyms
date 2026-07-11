import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';

/// Forgot password page for requesting a password reset.
class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSubmitted = useState(false);
    final submittedEmail = useState('');

    void handleSubmit() {
      if (formKey.currentState?.saveAndValidate() ?? false) {
        final email = formKey.currentState!.value['email'] as String;
        submittedEmail.value = email;
        isSubmitted.value = true;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.auth.forgotPasswordTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: isSubmitted.value
                ? _buildSuccessContent(context, submittedEmail.value)
                : _buildFormContent(context, formKey, handleSubmit),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          t.auth.checkEmail,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          t.auth.resetLinkSent(email: email),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.auth.backToLogin),
        ),
      ],
    );
  }

  Widget _buildFormContent(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
    VoidCallback onSubmit,
  ) {
    return FormBuilder(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_reset_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            t.auth.forgotPasswordTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t.auth.forgotPasswordSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              labelText: t.fields.email,
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: true,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onSubmit,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(t.auth.sendResetLink),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.auth.backToLogin),
          ),
        ],
      ),
    );
  }
}
