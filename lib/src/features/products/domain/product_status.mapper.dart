// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_status.dart';

class ProductStatusMapper extends EnumMapper<ProductStatus> {
  ProductStatusMapper._();

  static ProductStatusMapper? _instance;
  static ProductStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductStatusMapper._());
    }
    return _instance!;
  }

  static ProductStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ProductStatus decode(dynamic value) {
    switch (value) {
      case r'inStock':
        return ProductStatus.inStock;
      case r'outOfStock':
        return ProductStatus.outOfStock;
      case r'lowStock':
        return ProductStatus.lowStock;
      case r'noThreshold':
        return ProductStatus.noThreshold;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ProductStatus self) {
    switch (self) {
      case ProductStatus.inStock:
        return r'inStock';
      case ProductStatus.outOfStock:
        return r'outOfStock';
      case ProductStatus.lowStock:
        return r'lowStock';
      case ProductStatus.noThreshold:
        return r'noThreshold';
    }
  }
}

extension ProductStatusMapperExtension on ProductStatus {
  String toValue() {
    ProductStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ProductStatus>(this) as String;
  }
}

