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
  final List<String> validBranches;
  final bool isActive;
  final bool isFavorite;
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
    this.validBranches = const [],
    this.isActive = true,
    this.isFavorite = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MembershipDto.fromRecord(RecordModel record) {
    final json = record.toJson();
    return MembershipDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      durationDays: record.get<int>('durationDays'),
      price: record.getDoubleValue('price'),
      branch: record.getStringValue('branch'),
      validBranches: _parseIdList(json['validBranches']),
      isActive: record.getBoolValue('isActive'),
      isFavorite: record.getBoolValue('isFavorite'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  static List<String> _parseIdList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  /// Converts the DTO to a domain Membership entity.
  Membership toEntity() {
    return Membership(
      id: id,
      name: name,
      description: description != null && description!.isNotEmpty
          ? description
          : null,
      durationDays: durationDays,
      price: price,
      branchId: branch,
      validBranches: validBranches,
      isActive: isActive,
      isFavorite: isFavorite,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
