import 'package:dart_mappable/dart_mappable.dart';

import 'organization_dns_status.dart';
import 'organization_setup_status.dart';

part 'organization.mapper.dart';

/// Organization domain model.
///
/// Represents a tenant in the org > branch hierarchy. Controls branding
/// (seed color, logos, splash background) shown for its branches and users.
@MappableClass()
class Organization with OrganizationMappable {
  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    this.displayName,
    this.seedColor,
    this.logoLightUrl,
    this.logoTransparentUrl,
    this.splashBackgroundColor,
    this.subdomain,
    this.dnsStatus = OrganizationDnsStatus.pending,
    this.dnsError,
    this.dnsLastAttempt,
    this.setupStatus = OrganizationSetupStatus.pendingSetup,
    this.setupCompletedAt,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Full organization name (e.g. "Kylie Gym").
  final String name;

  /// URL-safe slug for the organization.
  final String slug;

  /// Display name shown as the app title/branding. Falls back to [name].
  final String? displayName;

  /// Hex seed color (e.g. `#1E88E5`) driving the app's ColorScheme.
  final String? seedColor;

  /// Pre-computed URL for the light-background logo, if uploaded.
  final String? logoLightUrl;

  /// Pre-computed URL for the transparent-background logo, if uploaded.
  final String? logoTransparentUrl;

  /// Hex background color for the in-app/web post-boot loading screen.
  final String? splashBackgroundColor;

  /// Optional legacy hostname field (DNS linking is no longer required).
  final String? subdomain;

  /// Optional legacy DNS status (not required for onboarding).
  final OrganizationDnsStatus dnsStatus;

  /// Optional legacy DNS error message.
  final String? dnsError;

  /// Optional legacy timestamp of the last DNS provisioning attempt.
  final DateTime? dnsLastAttempt;

  /// Onboarding lifecycle (`pending_setup` | `ready`).
  final OrganizationSetupStatus setupStatus;

  /// When setup was marked complete.
  final DateTime? setupCompletedAt;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// The name to show in UI/branding — [displayName] if set, else [name].
  String get effectiveDisplayName {
    final trimmed = displayName?.trim() ?? '';
    return trimmed.isNotEmpty ? trimmed : name;
  }
}
