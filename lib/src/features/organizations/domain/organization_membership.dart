/// Status of a user's membership in an organization.
enum OrganizationMembershipStatus {
  active,
  suspended;

  static OrganizationMembershipStatus fromString(String? value) {
    switch (value) {
      case 'suspended':
        return OrganizationMembershipStatus.suspended;
      case 'active':
      default:
        return OrganizationMembershipStatus.active;
    }
  }

  String get wireValue => name;
}

/// A user's role assignment within a single organization.
class OrganizationMembership {
  const OrganizationMembership({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.roleId,
    this.status = OrganizationMembershipStatus.active,
    this.invitedById,
    this.joinedAt,
  });

  final String id;
  final String userId;
  final String organizationId;
  final String roleId;
  final OrganizationMembershipStatus status;
  final String? invitedById;
  final DateTime? joinedAt;

  bool get isActive => status == OrganizationMembershipStatus.active;
}
