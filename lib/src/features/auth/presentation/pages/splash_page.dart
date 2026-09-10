import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../controllers/auth_controller.dart';

/// Splash page shown while the app is initializing.
///
/// Displayed during auth state initialization on app startup.
/// The router handles navigation based on auth state - this page
/// simply watches auth state and displays a warming-up loading UI.
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state - router will redirect when auth completes
    ref.watch(authControllerProvider);

    final verbIndex = useState(0);
    final ellipsisStep = useState(0);

    useEffect(() {
      final verbTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
        verbIndex.value = (verbIndex.value + 1) % splashLoadingVerbs.length;
      });
      final ellipsisTimer = Timer.periodic(
        const Duration(milliseconds: 400),
        (_) {
          ellipsisStep.value = (ellipsisStep.value + 1) % 3;
        },
      );
      return () {
        verbTimer.cancel();
        ellipsisTimer.cancel();
      };
    }, const []);

    final dots = '.' * (ellipsisStep.value + 1);
    final verbText = '${splashLoadingVerbs[verbIndex.value]}$dots';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icons.appIconTransparent.image(width: 150, height: 150),
            const SizedBox(height: 24),
            Text(
              t.auth.almostThereWarmingUp,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF999999),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              verbText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFBBBBBB),
                    letterSpacing: 0.02 * 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// English loading verbs (same set as the web HTML splash).
const splashLoadingVerbs = [
  'Loading',
  'Initializing',
  'Bootstrapping',
  'Preparing',
  'Warming up',
  'Assembling',
  'Hydrating',
  'Compiling',
  'Unpacking',
  'Provisioning',
  'Orchestrating',
  'Calibrating',
  'Spinning up',
  'Syncing',
  'Connecting',
  'Fetching',
  'Resolving',
  'Configuring',
  'Priming',
  'Awakening',
  'Igniting',
  'Launching',
  'Mounting',
  'Wiring',
  'Linking',
  'Caching',
  'Buffering',
  'Streaming',
  'Decoding',
  'Rendering',
  'Composing',
  'Building',
  'Crafting',
  'Forging',
  'Brewing',
  'Conjuring',
  'Summoning',
  'Materializing',
  'Manifesting',
  'Engaging',
  'Activating',
  'Enabling',
  'Aligning',
  'Tuning',
  'Polishing',
  'Finishing',
  'Finalizing',
  'Settling in',
  'Getting ready',
  'Almost there',
];
