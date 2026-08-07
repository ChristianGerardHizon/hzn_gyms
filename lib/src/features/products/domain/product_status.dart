import 'package:dart_mappable/dart_mappable.dart';

part 'product_status.mapper.dart';

/// Inventory status for products.
@MappableEnum()
enum ProductStatus {
  inStock,
  outOfStock,
  lowStock,
  noThreshold;

  /// Display name for the status.
  String get displayName {
    switch (this) {
      case ProductStatus.inStock:
        return 'In Stock';
      case ProductStatus.outOfStock:
        return 'Out of Stock';
      case ProductStatus.lowStock:
        return 'Low Stock';
      case ProductStatus.noThreshold:
        return 'Not Tracked';
    }
  }
}
