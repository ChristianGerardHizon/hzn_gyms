import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../products/data/dto/product_dto.dart';
import '../../domain/pos_group_item.dart';

part 'pos_group_item_dto.mapper.dart';

/// Data Transfer Object for PosGroupItem from PocketBase.
@MappableClass()
class PosGroupItemDto with PosGroupItemDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String group;
  final String? product;
  final int sortOrder;
  final String? created;
  final String? updated;

  const PosGroupItemDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.group,
    this.product,
    this.sortOrder = 0,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory PosGroupItemDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return PosGroupItemDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      group: json['group'] as String? ?? '',
      product: json['product'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain PosGroupItem entity.
  ///
  /// Accepts an optional expanded RecordModel for product.
  PosGroupItem toEntity({
    RecordModel? productExpanded,
  }) {
    return PosGroupItem(
      id: id,
      groupId: group,
      productId: product != null && product!.isNotEmpty ? product : null,
      sortOrder: sortOrder,
      product: productExpanded != null
          ? ProductDto.fromRecord(productExpanded).toEntity()
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
