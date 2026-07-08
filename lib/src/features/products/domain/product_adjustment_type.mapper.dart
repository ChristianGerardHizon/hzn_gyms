// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_adjustment_type.dart';

class ProductAdjustmentTypeMapper extends EnumMapper<ProductAdjustmentType> {
  ProductAdjustmentTypeMapper._();

  static ProductAdjustmentTypeMapper? _instance;
  static ProductAdjustmentTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductAdjustmentTypeMapper._());
    }
    return _instance!;
  }

  static ProductAdjustmentType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ProductAdjustmentType decode(dynamic value) {
    switch (value) {
      case r'product':
        return ProductAdjustmentType.product;
      case r'productStock':
        return ProductAdjustmentType.productStock;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ProductAdjustmentType self) {
    switch (self) {
      case ProductAdjustmentType.product:
        return r'product';
      case ProductAdjustmentType.productStock:
        return r'productStock';
    }
  }
}

extension ProductAdjustmentTypeMapperExtension on ProductAdjustmentType {
  String toValue() {
    ProductAdjustmentTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ProductAdjustmentType>(this)
        as String;
  }
}

