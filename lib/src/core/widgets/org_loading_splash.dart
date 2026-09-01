import 'package:flutter/material.dart';

/// Minimal, org-agnostic loading screen shown while the current
/// organization is being resolved (from hostname/auth/persisted choice)
/// before any login UI renders.
///
/// Deliberately uses a static default background — the whole point of this
/// screen is that the organization (and its `splashBackgroundColor`) isn't
/// known yet. See `effectiveSplashBackgroundColorProvider` for the org-aware
/// background used once resolution completes elsewhere in the app.
class OrgLoadingSplash extends StatelessWidget {
  const OrgLoadingSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
