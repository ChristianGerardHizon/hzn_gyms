import 'dart:async';
import 'dart:math' as math;

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

/// HZN brand green sampled from the logo mark.
const _kBrandGreen = Color(0xFF02F268);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);

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
    final isGoogleSigningIn = useState(false);
    final cooldownSeconds = useState(0);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    // Never block the email step on global auth loading — Google OAuth can hang
    // forever if the popup/tab is closed, which used to leave the email field
    // disabled. Password/OTP still use short-lived HTTP `isLoading`.
    final formBusy =
        isSendingOtp.value || (isLoading && loginStep.value == _LoginStep.auth);
    final awaitingCode =
        authMethod.value == _AuthMethod.otp && otpId.value != null;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        // Persist credentials in the platform password manager when supported.
        TextInput.finishAutofillContext();
        ref.read(authControllerProvider.notifier).login(email.value, password);
      }
    }

    Future<void> handleGoogleLogin() async {
      if (isGoogleSigningIn.value) return;
      errorMessage.value = null;
      isGoogleSigningIn.value = true;
      try {
        await ref.read(authControllerProvider.notifier).loginWithGoogle();
      } finally {
        if (context.mounted) isGoogleSigningIn.value = false;
      }
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
      if (loginStep.value == _LoginStep.auth) {
        return t.auth.signInToContinue;
      }
      return t.auth.signInToContinue;
    }

    final fieldDecoration = InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? _kSurfaceBorder : scheme.outlineVariant,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? _kSurfaceBorder : scheme.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kBrandGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
    );

    Widget primaryButton({
      required VoidCallback? onPressed,
      required Widget child,
    }) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: _kBrandGreen,
            foregroundColor: _kInk,
            disabledBackgroundColor: _kBrandGreen.withValues(alpha: 0.35),
            disabledForegroundColor: _kInk.withValues(alpha: 0.55),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          child: child,
        ),
      );
    }

    Widget formBody() {
      if (loginStep.value == _LoginStep.email) {
        return Column(
          key: const ValueKey('email'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormBuilderTextField(
              name: 'email',
              enabled: !formBusy,
              initialValue: email.value.isEmpty ? null : email.value,
              decoration: InputDecoration(
                labelText: t.fields.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.username,
              ],
              autocorrect: false,
              enableSuggestions: false,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
              onSubmitted: formBusy ? null : (_) => handleContinue(),
            ),
            const SizedBox(height: 20),
            primaryButton(
              onPressed: (formBusy || isGoogleSigningIn.value)
                  ? null
                  : handleContinue,
              child: Text(t.auth.continueButton),
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      t.auth.orDivider,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              _GoogleSignInButton(
                onPressed: (formBusy || isGoogleSigningIn.value)
                    ? null
                    : handleGoogleLogin,
                label: isGoogleSigningIn.value
                    ? t.auth.signingIn
                    : t.auth.continueWithGoogle,
              ),
            ],
          ],
        );
      }

      if (!awaitingCode) {
        return Column(
          key: const ValueKey('password'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _kBrandGreen.withValues(alpha: isDark ? 0.08 : 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _kBrandGreen.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kBrandGreen.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: _kBrandGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      email.value,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: formBusy ? null : goToEmailStep,
                    style: TextButton.styleFrom(
                      foregroundColor: _kBrandGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(t.auth.changeEmail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Keeps username+password in one autofill context across steps.
            Offstage(
              offstage: true,
              child: TextFormField(
                initialValue: email.value,
                readOnly: true,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            FormBuilderTextField(
              name: 'password',
              enabled: !formBusy,
              decoration: InputDecoration(
                labelText: t.fields.password,
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: formBusy
                      ? null
                      : () {
                          obscurePassword.value = !obscurePassword.value;
                        },
                ),
              ),
              obscureText: obscurePassword.value,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              autocorrect: false,
              enableSuggestions: false,
              validator: FormBuilderValidators.required(),
              onSubmitted: formBusy ? null : (_) => handleLogin(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: formBusy
                    ? null
                    : () => const ForgotPasswordRoute().go(context),
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
                ),
                child: Text(t.auth.forgotPassword),
              ),
            ),
            const SizedBox(height: 4),
            primaryButton(
              onPressed: formBusy ? null : handleLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: _kInk,
                      ),
                    )
                  : Text(t.auth.loginButton),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed:
                  formBusy ? null : () => handleSendOtp(isResend: false),
              style: TextButton.styleFrom(foregroundColor: _kBrandGreen),
              child: isSendingOtp.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.auth.signInWithEmailCode),
            ),
          ],
        );
      }

      return Column(
        key: const ValueKey('otp'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderTextField(
            name: 'otpCode',
            enabled: !formBusy,
            decoration: InputDecoration(
              labelText: t.auth.enterLoginCode,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode],
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              fontSize: 22,
              letterSpacing: 8,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(6),
              FormBuilderValidators.maxLength(6),
            ]),
            onSubmitted: formBusy ? null : (_) => handleVerifyOtp(),
          ),
          const SizedBox(height: 20),
          primaryButton(
            onPressed: formBusy ? null : handleVerifyOtp,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: _kInk,
                    ),
                  )
                : Text(t.auth.verifyLoginCode),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed:
                canResend ? () => handleSendOtp(isResend: true) : null,
            style: TextButton.styleFrom(foregroundColor: _kBrandGreen),
            child: Text(
              cooldownSeconds.value > 0
                  ? t.auth.resendLoginCodeCooldown(
                      seconds: cooldownSeconds.value,
                    )
                  : t.auth.resendLoginCode,
            ),
          ),
          TextButton(
            onPressed: formBusy ? null : switchToPasswordMethod,
            child: Text(t.auth.backToPasswordLogin),
          ),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginAtmosphere()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const padding = EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                );

                return SingleChildScrollView(
                  padding: padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - padding.vertical,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AutofillGroup(
                          child: FormBuilder(
                            key: formKey,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: fieldDecoration,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _LoginBrandHeader(),
                                  const SizedBox(height: 10),
                                  Text(
                                    appTitle,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    subtitle(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.62,
                                          ),
                                          height: 1.35,
                                        ),
                                  ),
                                  const SizedBox(height: 28),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? _kSurface.withValues(alpha: 0.92)
                                          : scheme.surface.withValues(
                                              alpha: 0.94,
                                            ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isDark
                                            ? _kSurfaceBorder
                                            : scheme.outlineVariant.withValues(
                                                alpha: 0.7,
                                              ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _kBrandGreen.withValues(
                                            alpha: isDark ? 0.08 : 0.06,
                                          ),
                                          blurRadius: 32,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? 0.35 : 0.08,
                                          ),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        22,
                                        24,
                                        22,
                                        20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (errorMessage.value != null) ...[
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: scheme.error.withValues(
                                                  alpha: 0.12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: scheme.error
                                                      .withValues(alpha: 0.55),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    color: scheme.error,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      errorMessage.value!,
                                                      style: TextStyle(
                                                        color: scheme.error,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            child: formBody(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  const AppVersionIndicator(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Google Identity-style "Continue with Google" button (white + multicolor G).
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.onPressed,
    required this.label,
  });

  final VoidCallback? onPressed;
  final String label;

  static const _bg = Color(0xFFFFFFFF);
  static const _fg = Color(0xFF1F1F1F);
  static const _border = Color(0xFF747775);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Material(
        color: _bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: Image(
                    image: AssetImage('assets/icons/google_g.png'),
                    width: 20,
                    height: 20,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginBrandHeader extends StatelessWidget {
  const _LoginBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kBrandGreen.withValues(alpha: 0.28),
                blurRadius: 42,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Assets.icons.appIconTransparent.image(
            width: 132,
            height: 132,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

/// Soft brand atmosphere behind the login form (gradients only — no assets).
class _LoginAtmosphere extends StatelessWidget {
  const _LoginAtmosphere();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? _kInk : const Color(0xFFF3F4F6);

    return DecoratedBox(
      decoration: BoxDecoration(color: base),
      child: CustomPaint(
        painter: _LoginGlowPainter(
          isDark: isDark,
          green: _kBrandGreen,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LoginGlowPainter extends CustomPainter {
  _LoginGlowPainter({required this.isDark, required this.green});

  final bool isDark;
  final Color green;

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.85),
        radius: 1.05,
        colors: [
          green.withValues(alpha: isDark ? 0.22 : 0.16),
          green.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);

    final sideGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.1, 0.35),
        radius: 0.9,
        colors: [
          green.withValues(alpha: isDark ? 0.10 : 0.07),
          green.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);

    final bottomWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          (isDark ? Colors.black : Colors.white).withValues(alpha: 0.35),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, topGlow);
    canvas.drawRect(Offset.zero & size, sideGlow);
    canvas.drawRect(Offset.zero & size, bottomWash);

    // Subtle grid lines for tech texture (very low contrast).
    final grid = Paint()
      ..color = green.withValues(alpha: isDark ? 0.035 : 0.04)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Soft vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: math.sqrt2,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _LoginGlowPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.green != green;
  }
}
