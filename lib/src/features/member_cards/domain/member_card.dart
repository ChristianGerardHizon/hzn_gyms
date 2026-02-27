import 'package:dart_mappable/dart_mappable.dart';

part 'member_card.mapper.dart';

/// Status of a member's physical ID card.
@MappableEnum()
enum MemberCardStatus {
  active,
  lost,
  deactivated;

  String get displayName {
    switch (this) {
      case MemberCardStatus.active:
        return 'Active';
      case MemberCardStatus.lost:
        return 'Lost';
      case MemberCardStatus.deactivated:
        return 'Deactivated';
    }
  }
}

/// A physical ID card linked to a gym member.
///
/// Members can have multiple cards (e.g., replacement cards).
/// Each card has a unique [cardValue] used for RFID/barcode check-in.
@MappableClass()
class MemberCard with MemberCardMappable {
  const MemberCard({
    required this.id,
    required this.memberId,
    required this.cardValue,
    required this.status,
    this.label,
    this.deactivatedAt,
    this.notes,
    this.memberName,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Member who owns this card.
  final String memberId;

  /// Unique identifier encoded on the physical card.
  final String cardValue;

  /// Current card status.
  final MemberCardStatus status;

  /// Human-readable name (e.g., "Primary Card").
  final String? label;

  /// When the card was deactivated or reported lost.
  final DateTime? deactivatedAt;

  /// Optional notes.
  final String? notes;

  /// Member name (from expand, for display).
  final String? memberName;

  /// Creation timestamp (also serves as issued date).
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether the card is currently active.
  bool get isActive => status == MemberCardStatus.active;
}
