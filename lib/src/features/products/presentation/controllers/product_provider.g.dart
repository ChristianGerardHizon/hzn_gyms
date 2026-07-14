// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single product by ID.
///
/// For lot-tracked products, this will automatically sync the product's
/// quantity from its lots to ensure the stock status is accurate.

@ProviderFor(product)
final productProvider = ProductFamily._();

/// Provider for a single product by ID.
///
/// For lot-tracked products, this will automatically sync the product's
/// quantity from its lots to ensure the stock status is accurate.

final class ProductProvider
    extends
        $FunctionalProvider<AsyncValue<Product?>, Product?, FutureOr<Product?>>
    with $FutureModifier<Product?>, $FutureProvider<Product?> {
  /// Provider for a single product by ID.
  ///
  /// For lot-tracked products, this will automatically sync the product's
  /// quantity from its lots to ensure the stock status is accurate.
  ProductProvider._({
    required ProductFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productHash();

  @override
  String toString() {
    return r'productProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Product?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Product?> create(Ref ref) {
    final argument = this.argument as String;
    return product(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productHash() => r'b33bb1473e9d7e53a753e1cff719d1fd48f1d038';

/// Provider for a single product by ID.
///
/// For lot-tracked products, this will automatically sync the product's
/// quantity from its lots to ensure the stock status is accurate.

final class ProductFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Product?>, String> {
  ProductFamily._()
    : super(
        retry: null,
        name: r'productProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a single product by ID.
  ///
  /// For lot-tracked products, this will automatically sync the product's
  /// quantity from its lots to ensure the stock status is accurate.

  ProductProvider call(String id) =>
      ProductProvider._(argument: id, from: this);

  @override
  String toString() => r'productProvider';
}
