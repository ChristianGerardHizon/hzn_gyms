import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../products/data/dto/product_dto.dart';
import '../../domain/sale_item.dart';

part 'sale_item_dto.mapper.dart';

@MappableClass()
class SaleItemDto with SaleItemDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String sale;
  final String product;
  final String productName;
  final num quantity;
  final num unitPrice;
  final num subtotal;
  final String? productLot;
  final String? lotNumber;
  final String? itemType;
  final String? created;
  final String? updated;

  const SaleItemDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.sale,
    required this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.productLot,
    this.lotNumber,
    this.itemType,
    this.created,
    this.updated,
  });

  factory SaleItemDto.fromRecord(RecordModel record) {
    return SaleItemDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      sale: record.getStringValue('sale'),
      product: record.getStringValue('product'),
      productName: record.getStringValue('productName'),
      quantity: record.getDoubleValue('quantity'),
      unitPrice: record.getDoubleValue('unitPrice'),
      subtotal: record.getDoubleValue('subtotal'),
      productLot: record.getStringValue('productLot'),
      lotNumber: record.getStringValue('lotNumber'),
      itemType: record.getStringValue('itemType'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  SaleItem toEntity({RecordModel? productExpanded}) {
    return SaleItem(
      id: id,
      saleId: sale,
      productId: product,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      productLotId: productLot,
      lotNumber: lotNumber,
      itemType: itemType != null && itemType!.isNotEmpty ? itemType : null,
      product: productExpanded != null
          ? ProductDto.fromRecord(productExpanded).toEntity()
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
