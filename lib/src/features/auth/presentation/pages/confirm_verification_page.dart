import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/auth.routes.dart';
import '../controllers/auth_controller.dart';

/// Confirms email verification from the link token in the email.
class ConfirmVerificationPage extends HookConsumerWidget {
  const ConfirmVerificationPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = useState<_ConfirmStatus>(_ConfirmStatus.loading);
    final didRun = useRef(false);

    useEffect(() {
      if (didRun.value) return null;
      didRun.value = true;

      Future.microtask(() async {
        if (token.isEmpty) {
          status.value = _ConfirmStatus.failure;
          return;
        }
        final ok = await ref
            .read(authControllerProvider.notifier)
            .confirmVerification(token);
        if (!context.mounted) return;
        status.value = ok ? _ConfirmStatus.success : _ConfirmStatus.failure;
        // Router redirect sends verified users into the app.
      });
      return null;
    }, [token]);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: switch (status.value) {
                _ConfirmStatus.loading => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      t.auth.confirmingVerification,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                _ConfirmStatus.success => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.auth.verificationSuccess,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                _ConfirmStatus.failure => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.auth.verificationFailed,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => const VerifyEmailRoute().go(context),
                      child: Text(t.auth.backToVerifyEmail),
                    ),
                    TextButton(
                      onPressed: () => const LoginRoute().go(context),
                      child: Text(t.auth.backToLogin),
                    ),
                  ],
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum _ConfirmStatus { loading, success, failure }
