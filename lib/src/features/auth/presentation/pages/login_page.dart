import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/widgets/app_version_indicator.dart';
import '../controllers/auth_controller.dart';
import '../login_error_message.dart';

/// Cooldown between OTP resends (abuse prevention).
const kLoginOtpResendCooldown = Duration(seconds: 60);

/// Login page for user authentication.
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final obscurePassword = useState(true);
    final errorMessage = useState<String?>(null);
    final otpMode = useState(false);
    final otpId = useState<String?>(null);
    final otpEmail = useState('');
    final isSendingOtp = useState(false);
    final cooldownSeconds = useState(0);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final formBusy = isLoading || isSendingOtp.value;

    useEffect(() {
      Timer? timer;
      if (cooldownSeconds.value <= 0) return null;
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (cooldownSeconds.value <= 1) {
          cooldownSeconds.value = 0;
          timer?.cancel();
        } else {
          cooldownSeconds.value = cooldownSeconds.value - 1;
        }
      });
      return timer.cancel;
    }, [cooldownSeconds.value > 0]);

    // Listen for auth errors (navigation on success is handled in router.dart).
    ref.listen(authControllerProvider, (prev, next) {
      if (!context.mounted) return;

      if (next.hasError) {
        errorMessage.value = loginErrorMessage(next.error);
      }
    });

    void handleLogin() {
      if (formKey.currentState?.saveAndValidate() ?? false) {
        errorMessage.value = null;
        final values = formKey.currentState!.value;
        ref
            .read(authControllerProvider.notifier)
            .login(values['email'] as String, values['password'] as String);
      }
    }

    Future<void> handleGoogleLogin() async {
      errorMessage.value = null;
      await ref.read(authControllerProvider.notifier).loginWithGoogle();
    }

    Future<void> handleSendOtp({required bool isResend}) async {
      if (isSendingOtp.value || cooldownSeconds.value > 0) return;

      String email;
      if (isResend) {
        email = otpEmail.value;
      } else {
        final emailField = formKey.currentState?.fields['email'];
        final valid = emailField?.validate() ?? false;
        if (!valid) {
          formKey.currentState?.saveAndValidate();
          return;
        }
        email = (emailField?.value as String?)?.trim() ?? '';
        if (email.isEmpty) return;
      }

      errorMessage.value = null;
      isSendingOtp.value = true;
      final id = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(email);
      isSendingOtp.value = false;
      if (!context.mounted) return;

      if (id == null || id.isEmpty) {
        errorMessage.value = t.auth.loginCodeSendFailed;
        return;
      }

      otpId.value = id;
      otpEmail.value = email;
      cooldownSeconds.value = kLoginOtpResendCooldown.inSeconds;
    }

    Future<void> handleVerifyOtp() async {
      final id = otpId.value;
      if (id == null || id.isEmpty) return;
      if (formKey.currentState?.saveAndValidate() ?? false) {
        errorMessage.value = null;
        final code = formKey.currentState!.value['otpCode'] as String;
        await ref.read(authControllerProvider.notifier).loginWithOtp(id, code);
      }
    }

    void switchToOtpMode() {
      errorMessage.value = null;
      otpMode.value = true;
      otpId.value = null;
      otpEmail.value = '';
      cooldownSeconds.value = 0;
    }

    void switchToPasswordMode() {
      errorMessage.value = null;
      otpMode.value = false;
      otpId.value = null;
      otpEmail.value = '';
      cooldownSeconds.value = 0;
    }

    final awaitingCode = otpMode.value && otpId.value != null;
    final canResend = !isSendingOtp.value && cooldownSeconds.value == 0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = EdgeInsets.all(24);

            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - padding.vertical,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: FormBuilder(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Assets.icons.appIconTransparent.image(
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            appTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            awaitingCode
                                ? t.auth.loginCodeSent(email: otpEmail.value)
                                : t.auth.signInToContinue,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 48),

                          if (errorMessage.value != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.1),
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (!otpMode.value) ...[
                            FormBuilderTextField(
                              name: 'email',
                              enabled: !formBusy,
                              decoration: InputDecoration(
                                labelText: t.fields.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.email(),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'password',
                              enabled: !formBusy,
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
                                  onPressed: formBusy
                                      ? null
                                      : () {
                                          obscurePassword.value =
                                              !obscurePassword.value;
                                        },
                                ),
                              ),
                              obscureText: obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              validator: FormBuilderValidators.required(),
                              onSubmitted:
                                  formBusy ? null : (_) => handleLogin(),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: formBusy ? null : handleLogin,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: formBusy ? null : switchToOtpMode,
                              child: Text(t.auth.signInWithEmailCode),
                            ),
                            if (kIsWeb) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      t.auth.orDivider,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed:
                                    formBusy ? null : handleGoogleLogin,
                                icon: const Icon(Icons.g_mobiledata, size: 28),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(t.auth.continueWithGoogle),
                                ),
                              ),
                            ],
                          ] else if (!awaitingCode) ...[
                            FormBuilderTextField(
                              name: 'email',
                              enabled: !formBusy,
                              decoration: InputDecoration(
                                labelText: t.fields.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.email(),
                              ]),
                              onSubmitted: formBusy
                                  ? null
                                  : (_) => handleSendOtp(isResend: false),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: formBusy
                                  ? null
                                  : () => handleSendOtp(isResend: false),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: isSendingOtp.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(t.auth.sendLoginCode),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed:
                                  formBusy ? null : switchToPasswordMode,
                              child: Text(t.auth.backToPasswordLogin),
                            ),
                          ] else ...[
                            FormBuilderTextField(
                              name: 'otpCode',
                              enabled: !formBusy,
                              decoration: InputDecoration(
                                labelText: t.auth.enterLoginCode,
                                prefixIcon: const Icon(Icons.pin_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(6),
                                FormBuilderValidators.maxLength(6),
                              ]),
                              onSubmitted: formBusy
                                  ? null
                                  : (_) => handleVerifyOtp(),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: formBusy ? null : handleVerifyOtp,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(t.auth.verifyLoginCode),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: canResend
                                  ? () => handleSendOtp(isResend: true)
                                  : null,
                              child: Text(
                                cooldownSeconds.value > 0
                                    ? t.auth.resendLoginCodeCooldown(
                                        seconds: cooldownSeconds.value,
                                      )
                                    : t.auth.resendLoginCode,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  formBusy ? null : switchToPasswordMode,
                              child: Text(t.auth.backToPasswordLogin),
                            ),
                          ],
                          const SizedBox(height: 32),
                          const AppVersionIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
