import 'package:flutter/material.dart';

import '../assets/assets.gen.dart';

/// Minimal, org-agnostic loading screen shown while the current
/// organization is being resolved for a signed-in user (from their account
/// or a persisted super-admin choice) before the main shell renders.
///
/// Deliberately uses a static default background — the whole point of this
/// screen is that the organization (and its `splashBackgroundColor`) isn't
/// known yet. See `effectiveSplashBackgroundColorProvider` for the org-aware
/// background used once resolution completes elsewhere in the app.
class OrgLoadingSplash extends StatelessWidget {
  const OrgLoadingSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.appIconTransparent.image(width: 120, height: 120),
            const SizedBox(height: 24),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
