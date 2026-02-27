import 'package:dart_mappable/dart_mappable.dart';

part 'check_in.mapper.dart';

/// Method used for check-in.
@MappableEnum()
enum CheckInMethod {
  manual,
  rfid;

  String get displayName {
    switch (this) {
      case CheckInMethod.manual:
        return 'Manual';
      case CheckInMethod.rfid:
        return 'RFID';
    }
  }
}

/// A member check-in record.
///
/// Tracks when a member enters the gym, the method used,
/// and which staff processed it (for manual check-ins).
@MappableClass()
class CheckIn with CheckInMappable {
  const CheckIn({
    required this.id,
    required this.memberId,
    required this.branchId,
    required this.checkInTime,
    required this.method,
    this.checkedInBy,
    this.memberMembershipId,
    this.memberName,
    this.notes,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Member who checked in.
  final String memberId;

  /// Branch where check-in occurred.
  final String branchId;

  /// Time of check-in.
  final DateTime checkInTime;

  /// Method used for check-in.
  final CheckInMethod method;

  /// Staff who processed the check-in (manual only).
  final String? checkedInBy;

  /// Active membership at time of check-in.
  final String? memberMembershipId;

  /// Member name (from expand, for display).
  final String? memberName;

  /// Optional notes.
  final String? notes;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
