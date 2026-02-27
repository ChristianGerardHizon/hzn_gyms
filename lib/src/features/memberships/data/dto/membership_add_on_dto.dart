import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/membership_add_on.dart';

part 'membership_add_on_dto.mapper.dart';

/// Data Transfer Object for MembershipAddOn from PocketBase.
@MappableClass()
class MembershipAddOnDto with MembershipAddOnDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String membership;
  final String name;
  final String? description;
  final num price;
  final bool isActive;
  final String? created;
  final String? updated;

  const MembershipAddOnDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.membership,
    required this.name,
    this.description,
    required this.price,
    this.isActive = true,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MembershipAddOnDto.fromRecord(RecordModel record) {
    return MembershipAddOnDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      membership: record.getStringValue('membership'),
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      price: record.getDoubleValue('price'),
      isActive: record.getBoolValue('isActive'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain MembershipAddOn entity.
  MembershipAddOn toEntity() {
    return MembershipAddOn(
      id: id,
      membershipId: membership,
      name: name,
      description:
          description != null && description!.isNotEmpty ? description : null,
      price: price,
      isActive: isActive,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
