import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/member_membership_add_on.dart';

part 'member_membership_add_on_dto.mapper.dart';

/// Data Transfer Object for MemberMembershipAddOn from PocketBase.
@MappableClass()
class MemberMembershipAddOnDto with MemberMembershipAddOnDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String memberMembership;
  final String membershipAddOn;
  final String addOnName;
  final num price;
  final String? created;
  final String? updated;

  const MemberMembershipAddOnDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.memberMembership,
    required this.membershipAddOn,
    required this.addOnName,
    required this.price,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MemberMembershipAddOnDto.fromRecord(RecordModel record) {
    return MemberMembershipAddOnDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      memberMembership: record.getStringValue('memberMembership'),
      membershipAddOn: record.getStringValue('membershipAddOn'),
      addOnName: record.getStringValue('addOnName'),
      price: record.getDoubleValue('price'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain MemberMembershipAddOn entity.
  MemberMembershipAddOn toEntity() {
    return MemberMembershipAddOn(
      id: id,
      memberMembershipId: memberMembership,
      membershipAddOnId: membershipAddOn,
      addOnName: addOnName,
      price: price,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
