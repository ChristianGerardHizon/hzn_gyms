import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/member_membership.dart';

part 'member_membership_dto.mapper.dart';

/// Data Transfer Object for MemberMembership from PocketBase.
@MappableClass()
class MemberMembershipDto with MemberMembershipDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String member;
  final String membership;
  final String? startDate;
  final String? endDate;
  final String status;
  final String branch;
  final String? sale;
  final String? soldBy;
  final String? notes;
  final String? created;
  final String? updated;

  // Expanded fields
  final String? memberName;
  final String? membershipName;

  const MemberMembershipDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.member,
    required this.membership,
    this.startDate,
    this.endDate,
    required this.status,
    required this.branch,
    this.sale,
    this.soldBy,
    this.notes,
    this.created,
    this.updated,
    this.memberName,
    this.membershipName,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MemberMembershipDto.fromRecord(RecordModel record) {
    // Extract expanded member name
    final memberExpand = record.get<RecordModel?>('expand.member');
    final membershipExpand = record.get<RecordModel?>('expand.membership');

    return MemberMembershipDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      member: record.getStringValue('member'),
      membership: record.getStringValue('membership'),
      startDate: record.get<String>('startDate'),
      endDate: record.get<String>('endDate'),
      status: record.getStringValue('status'),
      branch: record.getStringValue('branch'),
      sale: record.getStringValue('saleId'),
      soldBy: record.getStringValue('soldBy'),
      notes: record.getStringValue('notes'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
      memberName: memberExpand?.getStringValue('name'),
      membershipName: membershipExpand?.getStringValue('name'),
    );
  }

  /// Converts the DTO to a domain MemberMembership entity.
  MemberMembership toEntity() {
    return MemberMembership(
      id: id,
      memberId: member,
      membershipId: membership,
      startDate: parseToLocal(startDate) ?? DateTime.now(),
      endDate: parseToLocal(endDate) ?? DateTime.now(),
      status: _parseStatus(status),
      branchId: branch,
      memberName: memberName,
      membershipName: membershipName,
      saleId: sale != null && sale!.isNotEmpty ? sale : null,
      soldBy: soldBy != null && soldBy!.isNotEmpty ? soldBy : null,
      notes: notes != null && notes!.isNotEmpty ? notes : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  static MemberMembershipStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return MemberMembershipStatus.active;
      case 'expired':
        return MemberMembershipStatus.expired;
      case 'cancelled':
        return MemberMembershipStatus.cancelled;
      case 'voided':
        return MemberMembershipStatus.voided;
      default:
        return MemberMembershipStatus.expired;
    }
  }
}
