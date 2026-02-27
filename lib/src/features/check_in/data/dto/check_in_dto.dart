import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/check_in.dart';

part 'check_in_dto.mapper.dart';

/// Data Transfer Object for CheckIn from PocketBase.
@MappableClass()
class CheckInDto with CheckInDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String member;
  final String branch;
  final String? checkInTime;
  final String method;
  final String? checkedInBy;
  final String? memberMembership;
  final String? notes;
  final String? created;
  final String? updated;

  // Expanded fields
  final String? memberName;

  const CheckInDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.member,
    required this.branch,
    this.checkInTime,
    required this.method,
    this.checkedInBy,
    this.memberMembership,
    this.notes,
    this.created,
    this.updated,
    this.memberName,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory CheckInDto.fromRecord(RecordModel record) {
    final memberExpand = record.get<RecordModel?>('expand.member');

    return CheckInDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      member: record.getStringValue('member'),
      branch: record.getStringValue('branch'),
      checkInTime: record.get<String>('checkInTime'),
      method: record.getStringValue('method'),
      checkedInBy: record.getStringValue('checkedInBy'),
      memberMembership: record.getStringValue('memberMembership'),
      notes: record.getStringValue('notes'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
      memberName: memberExpand?.getStringValue('name'),
    );
  }

  /// Converts the DTO to a domain CheckIn entity.
  CheckIn toEntity() {
    return CheckIn(
      id: id,
      memberId: member,
      branchId: branch,
      checkInTime: parseToLocal(checkInTime) ?? DateTime.now(),
      method: _parseMethod(method),
      checkedInBy:
          checkedInBy != null && checkedInBy!.isNotEmpty ? checkedInBy : null,
      memberMembershipId: memberMembership != null &&
              memberMembership!.isNotEmpty
          ? memberMembership
          : null,
      memberName: memberName,
      notes: notes != null && notes!.isNotEmpty ? notes : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  static CheckInMethod _parseMethod(String value) {
    switch (value.toLowerCase()) {
      case 'rfid':
        return CheckInMethod.rfid;
      case 'manual':
      default:
        return CheckInMethod.manual;
    }
  }
}
