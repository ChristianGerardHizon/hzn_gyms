import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/packages/theme/app_themes.dart';
import '../../../../core/utils/color_utils.dart';
import 'current_organization_controller.dart';

part 'organization_branding_providers.g.dart';

/// The seed color driving the app's [ColorScheme] — the current
/// organization's `seedColor` when set, else [AppThemes.defaultSeedColor].
@Riverpod(keepAlive: true)
Color effectiveSeedColor(Ref ref) {
  final org = ref.watch(currentOrganizationControllerProvider).value;
  return colorFromHex(org?.seedColor) ?? AppThemes.defaultSeedColor;
}

/// The app title shown in the app bar/browser tab — the current
/// organization's display name when resolved, else the env-aware fallback
/// from [appTitle].
@Riverpod(keepAlive: true)
String effectiveAppTitle(Ref ref) {
  final org = ref.watch(currentOrganizationControllerProvider).value;
  if (org != null) return org.effectiveDisplayName;
  return appTitle;
}

/// The transparent-background logo URL for the current organization, or
/// null when unresolved/unset — callers should fall back to the bundled
/// default asset (e.g. via `CachedImage`'s built-in placeholder).
@Riverpod(keepAlive: true)
String? effectiveLogoUrl(Ref ref) {
  final org = ref.watch(currentOrganizationControllerProvider).value;
  return org?.logoTransparentUrl;
}

/// Background color for the in-app/web post-boot loading screen.
///
/// Native OS splash (`flutter_native_splash.yaml`) is baked at build time
/// and cannot reflect this — see `OrgLoadingSplash`.
@Riverpod(keepAlive: true)
Color effectiveSplashBackgroundColor(Ref ref) {
  final org = ref.watch(currentOrganizationControllerProvider).value;
  return colorFromHex(org?.splashBackgroundColor) ?? Colors.black;
}
