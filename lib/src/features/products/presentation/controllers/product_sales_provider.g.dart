// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching a product's recent sales history.

@ProviderFor(productSales)
final productSalesProvider = ProductSalesFamily._();

/// Provider for fetching a product's recent sales history.

final class ProductSalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductSaleLine>>,
          List<ProductSaleLine>,
          FutureOr<List<ProductSaleLine>>
        >
    with
        $FutureModifier<List<ProductSaleLine>>,
        $FutureProvider<List<ProductSaleLine>> {
  /// Provider for fetching a product's recent sales history.
  ProductSalesProvider._({
    required ProductSalesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productSalesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productSalesHash();

  @override
  String toString() {
    return r'productSalesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductSaleLine>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductSaleLine>> create(Ref ref) {
    final argument = this.argument as String;
    return productSales(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductSalesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productSalesHash() => r'0a827ee5040b1c9bdc13fa633f7d12af5d77da25';

/// Provider for fetching a product's recent sales history.

final class ProductSalesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProductSaleLine>>, String> {
  ProductSalesFamily._()
    : super(
        retry: null,
        name: r'productSalesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching a product's recent sales history.

  ProductSalesProvider call(String productId) =>
      ProductSalesProvider._(argument: productId, from: this);

  @override
  String toString() => r'productSalesProvider';
}
