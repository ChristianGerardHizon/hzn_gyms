/// Onboarding lifecycle for a tenant organization.
enum OrganizationSetupStatus {
  pendingSetup('pending_setup'),
  ready('ready');

  const OrganizationSetupStatus(this.value);

  final String value;

  static OrganizationSetupStatus fromValue(String? raw) {
    if (raw == null || raw.isEmpty) return pendingSetup;
    for (final status in OrganizationSetupStatus.values) {
      if (status.value == raw) return status;
    }
    return pendingSetup;
  }

  bool get isReady => this == ready;
}
