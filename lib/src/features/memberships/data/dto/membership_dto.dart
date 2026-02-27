import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/membership.dart';

part 'membership_dto.mapper.dart';

/// Data Transfer Object for Membership plan from PocketBase.
@MappableClass()
class MembershipDto with MembershipDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? description;
  final int durationDays;
  final num price;
  final String branch;
  final bool isActive;
  final String? created;
  final String? updated;

  const MembershipDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.description,
    required this.durationDays,
    required this.price,
    required this.branch,
    this.isActive = true,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MembershipDto.fromRecord(RecordModel record) {
    return MembershipDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      durationDays: record.get<int>('durationDays'),
      price: record.getDoubleValue('price'),
      branch: record.getStringValue('branch'),
      isActive: record.getBoolValue('isActive'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain Membership entity.
  Membership toEntity() {
    return Membership(
      id: id,
      name: name,
      description:
          description != null && description!.isNotEmpty ? description : null,
      durationDays: durationDays,
      price: price,
      branchId: branch,
      isActive: isActive,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
