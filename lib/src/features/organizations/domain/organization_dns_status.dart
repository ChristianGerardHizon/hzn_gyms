import 'package:flutter/material.dart';

/// Porkbun DNS provisioning status for an [Organization]'s subdomain.
enum OrganizationDnsStatus {
  pending,
  created,
  failed;

  /// Parses the raw PocketBase `select` value, defaulting to [pending].
  static OrganizationDnsStatus fromValue(String? value) {
    switch (value) {
      case 'created':
        return OrganizationDnsStatus.created;
      case 'failed':
        return OrganizationDnsStatus.failed;
      default:
        return OrganizationDnsStatus.pending;
    }
  }

  /// The raw value stored in PocketBase.
  String get value => name;

  /// Display label for admin UI (e.g. the Organizations management screen).
  String get label {
    switch (this) {
      case OrganizationDnsStatus.pending:
        return 'Pending';
      case OrganizationDnsStatus.created:
        return 'Created';
      case OrganizationDnsStatus.failed:
        return 'Failed';
    }
  }

  /// Badge color for admin UI.
  Color get badgeColor {
    switch (this) {
      case OrganizationDnsStatus.pending:
        return Colors.amber;
      case OrganizationDnsStatus.created:
        return Colors.green;
      case OrganizationDnsStatus.failed:
        return Colors.red;
    }
  }
}
