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
import '../../../../core/routing/routes/auth.routes.dart';
import '../../../../core/widgets/app_version_indicator.dart';
import '../controllers/auth_controller.dart';
import '../login_error_message.dart';

/// Cooldown between OTP resends (abuse prevention).
const kLoginOtpResendCooldown = Duration(seconds: 60);

enum _LoginStep { email, auth }

enum _AuthMethod { password, otp }

/// Login page for user authentication.
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final obscurePassword = useState(true);
    final errorMessage = useState<String?>(null);
    final loginStep = useState(_LoginStep.email);
    final authMethod = useState(_AuthMethod.password);
    final email = useState('');
    final otpId = useState<String?>(null);
    final isSendingOtp = useState(false);
    final cooldownSeconds = useState(0);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final formBusy = isLoading || isSendingOtp.value;
    final awaitingCode =
        authMethod.value == _AuthMethod.otp && otpId.value != null;

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

    void clearOtpState() {
      otpId.value = null;
      cooldownSeconds.value = 0;
    }

    void goToEmailStep() {
      errorMessage.value = null;
      loginStep.value = _LoginStep.email;
      authMethod.value = _AuthMethod.password;
      clearOtpState();
    }

    void goToAuthStep(String nextEmail) {
      errorMessage.value = null;
      email.value = nextEmail;
      loginStep.value = _LoginStep.auth;
      authMethod.value = _AuthMethod.password;
      clearOtpState();
    }

    void handleContinue() {
      if (formKey.currentState?.saveAndValidate() ?? false) {
        final value =
            (formKey.currentState!.value['email'] as String?)?.trim() ?? '';
        if (value.isEmpty) return;
        goToAuthStep(value);
      }
    }

    void handleLogin() {
      if (formKey.currentState?.saveAndValidate() ?? false) {
        errorMessage.value = null;
        final password = formKey.currentState!.value['password'] as String;
        ref.read(authControllerProvider.notifier).login(email.value, password);
      }
    }

    Future<void> handleGoogleLogin() async {
      errorMessage.value = null;
      await ref.read(authControllerProvider.notifier).loginWithGoogle();
    }

    Future<void> handleSendOtp({required bool isResend}) async {
      if (isSendingOtp.value || cooldownSeconds.value > 0) return;

      final targetEmail = email.value.trim();
      if (targetEmail.isEmpty) return;

      errorMessage.value = null;
      isSendingOtp.value = true;
      final id = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(targetEmail);
      isSendingOtp.value = false;
      if (!context.mounted) return;

      if (id == null || id.isEmpty) {
        errorMessage.value = t.auth.loginCodeSendFailed;
        return;
      }

      authMethod.value = _AuthMethod.otp;
      otpId.value = id;
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

    void switchToPasswordMethod() {
      errorMessage.value = null;
      authMethod.value = _AuthMethod.password;
      clearOtpState();
    }

    final canResend = !isSendingOtp.value && cooldownSeconds.value == 0;

    String subtitle() {
      if (awaitingCode) {
        return t.auth.loginCodeSent(email: email.value);
      }
      return t.auth.signInToContinue;
    }

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
                            subtitle(),
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

                          if (loginStep.value == _LoginStep.email) ...[
                            FormBuilderTextField(
                              name: 'email',
                              enabled: !formBusy,
                              initialValue: email.value.isEmpty
                                  ? null
                                  : email.value,
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
                              onSubmitted:
                                  formBusy ? null : (_) => handleContinue(),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: formBusy ? null : handleContinue,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(t.auth.continueButton),
                              ),
                            ),
                            if (kIsWeb) ...[
                              const SizedBox(height: 16),
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
                            Text(
                              email.value,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: formBusy ? null : goToEmailStep,
                              child: Text(t.auth.changeEmail),
                            ),
                            const SizedBox(height: 8),
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: formBusy
                                    ? null
                                    : () =>
                                        const ForgotPasswordRoute().go(context),
                                child: Text(t.auth.forgotPassword),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                              onPressed: formBusy
                                  ? null
                                  : () => handleSendOtp(isResend: false),
                              child: isSendingOtp.value
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(t.auth.signInWithEmailCode),
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
                                  formBusy ? null : switchToPasswordMethod,
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
