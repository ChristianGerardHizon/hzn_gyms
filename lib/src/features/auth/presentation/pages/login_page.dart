import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/app_version_indicator.dart';
import '../controllers/auth_controller.dart';

/// Login page for user authentication.
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final obscurePassword = useState(true);
    final errorMessage = useState<String?>(null);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // Listen for auth state changes
    ref.listen(authControllerProvider, (prev, next) {
      if (!context.mounted) return;

      // On error, show error message
      if (next.hasError) {
        errorMessage.value = t.failures.invalidCredentials;
      }

      // On success, navigation is handled by router redirect (with pending URL support)
    });

    void handleLogin() {
      if (formKey.currentState?.saveAndValidate() ?? false) {
        // Clear any previous error
        errorMessage.value = null;
        final values = formKey.currentState!.value;
        ref.read(authControllerProvider.notifier).login(
              values['username'] as String,
              values['password'] as String,
            );
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Assets.icons.appIconTransparent.image(
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.common.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.signInToContinue,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Error message
                  if (errorMessage.value != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Username field
                  FormBuilderTextField(
                    name: 'username',
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: t.fields.username,
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  FormBuilderTextField(
                    name: 'password',
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: t.fields.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                obscurePassword.value = !obscurePassword.value;
                              },
                      ),
                    ),
                    obscureText: obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    validator: FormBuilderValidators.required(),
                    onSubmitted: isLoading ? null : (_) => handleLogin(),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  FilledButton(
                    onPressed: isLoading ? null : handleLogin,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(t.auth.loginButton),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App version indicator
                  const AppVersionIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
