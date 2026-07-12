/// Local-only sync status for offline-created or edited records.
enum SyncStatus {
  synced,
  pending,
  failed,
  conflict;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SyncStatus.synced,
    );
  }
}

/// Outbox entry entity types.
enum OutboxEntityType {
  member,
  sale,
  saleItem,
  memberMembership,
  memberMembershipAddOn;

  String get value => name;
}

/// Outbox operation types.
enum OutboxOperation {
  create,
  update;

  String get value => name;
}

/// Outbox entry status.
enum OutboxStatus {
  pending,
  synced,
  failed,
  conflict;

  String get value => name;

  static OutboxStatus fromString(String value) {
    return OutboxStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OutboxStatus.pending,
    );
  }
}

/// Lightweight view model for pending outbox UI.
class OutboxPendingItem {
  const OutboxPendingItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.status,
    required this.attempts,
    required this.clientRecordId,
    required this.createdAt,
    this.dependsOnId,
    this.lastError,
    this.payloadJson,
    this.hasAttachment = false,
  });

  final String id;
  final String entityType;
  final String operation;
  final String status;
  final int attempts;
  final String clientRecordId;
  final DateTime createdAt;
  final String? dependsOnId;
  final String? lastError;
  final String? payloadJson;
  final bool hasAttachment;

  String get displayTitle {
    final entity = switch (entityType) {
      'member' => 'Member',
      'sale' => 'Sale',
      'saleItem' => 'Sale Item',
      'memberMembership' => 'Membership',
      'memberMembershipAddOn' => 'Membership Add-On',
      _ => entityType,
    };
    final op = operation == 'create' ? 'Create' : 'Update';
    return '$op $entity';
  }
}
