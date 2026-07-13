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
  final int durationDays;
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
    this.durationDays = 0,
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
      durationDays: _readDurationDays(record),
      isActive: record.getBoolValue('isActive'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  static int _readDurationDays(RecordModel record) {
    try {
      final value = record.get<dynamic>('durationDays');
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Converts the DTO to a domain MembershipAddOn entity.
  MembershipAddOn toEntity() {
    return MembershipAddOn(
      id: id,
      membershipId: membership,
      name: name,
      description: description != null && description!.isNotEmpty
          ? description
          : null,
      price: price,
      durationDays: durationDays,
      isActive: isActive,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
