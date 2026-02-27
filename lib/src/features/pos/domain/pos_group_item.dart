import 'package:dart_mappable/dart_mappable.dart';

import '../../products/domain/product.dart';

part 'pos_group_item.mapper.dart';

/// POS Group Item domain model.
///
/// Represents a product assigned to a [PosGroup].
/// Acts as a many-to-many junction between groups and products.
@MappableClass()
class PosGroupItem with PosGroupItemMappable {
  const PosGroupItem({
    this.id = '',
    required this.groupId,
    this.productId,
    this.sortOrder = 0,
    this.product,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent group FK ID.
  final String groupId;

  /// Product FK ID.
  final String? productId;

  /// Display order within the group.
  final int sortOrder;

  /// Expanded product (populated from PocketBase expand).
  final Product? product;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this item is a product.
  bool get isProduct => productId != null && productId!.isNotEmpty;

  /// Display name from the expanded product.
  String get displayName => product?.name ?? '';

  /// Display price from the expanded product.
  num get displayPrice => product?.price ?? 0;

  /// Whether this item has a variable price.
  bool get hasVariablePrice => product?.isVariablePrice == true;
}
