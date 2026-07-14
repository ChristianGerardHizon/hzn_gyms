import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../controllers/auth_controller.dart';

/// Splash page shown while the app is initializing.
///
/// Displayed during auth state initialization on app startup.
/// The router handles navigation based on auth state - this page
/// simply watches auth state and displays a loading indicator.
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state - router will redirect when auth completes
    ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icons.appIconTransparent.image(width: 150, height: 150),
            const SizedBox(height: 24),
            Text(
              t.common.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
