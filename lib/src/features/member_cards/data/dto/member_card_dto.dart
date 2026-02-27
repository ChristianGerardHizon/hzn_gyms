import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/member_card.dart';

part 'member_card_dto.mapper.dart';

/// Data Transfer Object for MemberCard from PocketBase.
@MappableClass()
class MemberCardDto with MemberCardDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String member;
  final String cardValue;
  final String status;
  final String? label;
  final String? deactivatedAt;
  final String? notes;
  final String? created;
  final String? updated;

  // Expanded fields
  final String? memberName;

  const MemberCardDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.member,
    required this.cardValue,
    required this.status,
    this.label,
    this.deactivatedAt,
    this.notes,
    this.created,
    this.updated,
    this.memberName,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MemberCardDto.fromRecord(RecordModel record) {
    final memberExpand = record.get<RecordModel?>('expand.member');

    return MemberCardDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      member: record.getStringValue('member'),
      cardValue: record.getStringValue('cardValue'),
      status: record.getStringValue('status'),
      label: record.getStringValue('label'),
      deactivatedAt: record.get<String>('deactivatedAt'),
      notes: record.getStringValue('notes'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
      memberName: memberExpand?.getStringValue('name'),
    );
  }

  /// Converts the DTO to a domain MemberCard entity.
  MemberCard toEntity() {
    return MemberCard(
      id: id,
      memberId: member,
      cardValue: cardValue,
      status: _parseStatus(status),
      label: label != null && label!.isNotEmpty ? label : null,
      deactivatedAt: parseToLocal(deactivatedAt),
      notes: notes != null && notes!.isNotEmpty ? notes : null,
      memberName: memberName,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  static MemberCardStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return MemberCardStatus.active;
      case 'lost':
        return MemberCardStatus.lost;
      case 'deactivated':
        return MemberCardStatus.deactivated;
      default:
        return MemberCardStatus.deactivated;
    }
  }
}
