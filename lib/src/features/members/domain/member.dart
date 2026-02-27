import 'package:dart_mappable/dart_mappable.dart';

part 'member.mapper.dart';

/// Sex/gender options for members.
@MappableEnum()
enum MemberSex {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case MemberSex.male:
        return 'Male';
      case MemberSex.female:
        return 'Female';
      case MemberSex.other:
        return 'Other';
    }
  }
}

/// Member domain model.
///
/// Represents a gym member.
@MappableClass()
class Member with MemberMappable {
  const Member({
    required this.id,
    required this.name,
    this.photo,
    this.mobileNumber,
    this.dateOfBirth,
    this.address,
    this.sex,
    this.remarks,
    this.addedBy,
    this.rfidCardId,
    this.email,
    this.emergencyContact,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Member name.
  final String name;

  /// Profile photo URL (optional).
  final String? photo;

  /// Mobile/phone number (optional).
  final String? mobileNumber;

  /// Date of birth (optional).
  final DateTime? dateOfBirth;

  /// Address (optional).
  final String? address;

  /// Sex/gender (optional).
  final MemberSex? sex;

  /// Remarks/notes (optional).
  final String? remarks;

  /// User ID of who registered this member (optional).
  final String? addedBy;

  /// RFID card ID for check-in (optional).
  final String? rfidCardId;

  /// Email address (optional).
  final String? email;

  /// Emergency contact info (optional).
  final String? emergencyContact;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Display string for list tiles.
  String get subtitle => mobileNumber ?? '';
}
