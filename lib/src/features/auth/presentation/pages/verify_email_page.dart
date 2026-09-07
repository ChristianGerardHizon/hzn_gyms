import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../controllers/auth_controller.dart';

/// Cooldown between verification email resends (abuse prevention).
const kVerificationResendCooldown = Duration(seconds: 60);

/// Post-login gate: user must verify email before using the app.
class VerifyEmailPage extends HookConsumerWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).value;
    final email = auth?.user.email ?? '';
    final isSending = useState(false);
    final isRefreshing = useState(false);
    final cooldownSeconds = useState(0);
    final didAutoSend = useRef(false);

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

    Future<void> sendVerification({required bool showSuccess}) async {
      if (email.isEmpty || isSending.value || cooldownSeconds.value > 0) {
        return;
      }
      isSending.value = true;
      final ok = await ref
          .read(authControllerProvider.notifier)
          .requestVerification(email);
      isSending.value = false;
      if (!context.mounted) return;
      if (ok) {
        cooldownSeconds.value = kVerificationResendCooldown.inSeconds;
        if (showSuccess) {
          showSuccessSnackBar(context, message: t.auth.verificationEmailSent);
        }
      } else {
        showErrorSnackBar(context, message: t.auth.verificationEmailFailed);
      }
    }

    useEffect(() {
      if (didAutoSend.value || email.isEmpty) return null;
      didAutoSend.value = true;
      Future.microtask(() => sendVerification(showSuccess: false));
      return null;
    }, [email]);

    Future<void> handleContinue() async {
      isRefreshing.value = true;
      final ok = await ref.read(authControllerProvider.notifier).refresh();
      isRefreshing.value = false;
      if (!context.mounted) return;
      final verified = ref.read(authControllerProvider).value?.isVerified ?? false;
      if (!ok || !verified) {
        showErrorSnackBar(context, message: t.auth.stillUnverified);
      }
      // Router redirect advances when verified.
    }

    Future<void> handleLogout() async {
      await ref.read(authControllerProvider.notifier).logout();
    }

    final canResend = !isSending.value && cooldownSeconds.value == 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.auth.verifyEmailTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.auth.verifyEmailSubtitle(email: email),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isRefreshing.value ? null : handleContinue,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: isRefreshing.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.auth.verifyEmailContinue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: canResend
                        ? () => sendVerification(showSuccess: true)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: isSending.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              cooldownSeconds.value > 0
                                  ? t.auth.resendVerificationCooldown(
                                      seconds: cooldownSeconds.value,
                                    )
                                  : t.auth.resendVerification,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: handleLogout,
                    child: Text(t.auth.logoutButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
