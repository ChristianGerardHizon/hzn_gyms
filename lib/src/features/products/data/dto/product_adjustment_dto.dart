import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/product_adjustment.dart';
import '../../domain/product_adjustment_type.dart';

part 'product_adjustment_dto.mapper.dart';

/// Data Transfer Object for ProductAdjustment from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain ProductAdjustment.
@MappableClass()
class ProductAdjustmentDto with ProductAdjustmentDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String type;
  final num oldValue;
  final num newValue;
  final String? reason;
  final String? product;
  final String? productStock;
  final String? productLot;
  final String? sale;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const ProductAdjustmentDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.type,
    required this.oldValue,
    required this.newValue,
    this.reason,
    this.product,
    this.productStock,
    this.productLot,
    this.sale,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory ProductAdjustmentDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return ProductAdjustmentDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      type: json['type'] as String? ?? 'product',
      oldValue: json['oldValue'] as num? ?? 0,
      newValue: json['newValue'] as num? ?? 0,
      reason: json['reason'] as String?,
      product: json['product'] as String?,
      productStock: json['productStock'] as String?,
      productLot: json['productLot'] as String?,
      sale: json['sale'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain ProductAdjustment entity.
  ProductAdjustment toEntity() {
    return ProductAdjustment(
      id: id,
      type: _parseType(type),
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
      productId: product,
      productStockId: productStock,
      productLotId: productLot,
      saleId: sale,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  /// Parses the type string to enum.
  ProductAdjustmentType _parseType(String value) {
    switch (value) {
      case 'productStock':
        return ProductAdjustmentType.productStock;
      case 'product':
      default:
        return ProductAdjustmentType.product;
    }
  }

  /// Creates a JSON body for creating a new adjustment in PocketBase.
  static Map<String, dynamic> toCreateBody({
    required ProductAdjustmentType type,
    required num oldValue,
    required num newValue,
    String? reason,
    String? productId,
    String? productStockId,
    String? productLotId,
    String? saleId,
  }) {
    return {
      'type': type.name,
      'oldValue': oldValue,
      'newValue': newValue,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
      if (productId != null && productId.isNotEmpty) 'product': productId,
      if (productStockId != null && productStockId.isNotEmpty)
        'productStock': productStockId,
      if (productLotId != null && productLotId.isNotEmpty)
        'productLot': productLotId,
      if (saleId != null && saleId.isNotEmpty) 'sale': saleId,
    };
  }
}
