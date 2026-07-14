// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_product_stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that calculates stock status for a product.
///
/// Handles both lot-tracked and non-lot-tracked products.
/// For lot-tracked products, sums all lot quantities to determine stock status.

@ProviderFor(posProductStock)
final posProductStockProvider = PosProductStockFamily._();

/// Provider that calculates stock status for a product.
///
/// Handles both lot-tracked and non-lot-tracked products.
/// For lot-tracked products, sums all lot quantities to determine stock status.

final class PosProductStockProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProductStatus>,
          ProductStatus,
          FutureOr<ProductStatus>
        >
    with $FutureModifier<ProductStatus>, $FutureProvider<ProductStatus> {
  /// Provider that calculates stock status for a product.
  ///
  /// Handles both lot-tracked and non-lot-tracked products.
  /// For lot-tracked products, sums all lot quantities to determine stock status.
  PosProductStockProvider._({
    required PosProductStockFamily super.from,
    required Product super.argument,
  }) : super(
         retry: null,
         name: r'posProductStockProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$posProductStockHash();

  @override
  String toString() {
    return r'posProductStockProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProductStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProductStatus> create(Ref ref) {
    final argument = this.argument as Product;
    return posProductStock(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PosProductStockProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$posProductStockHash() => r'af8754dde9e5729b8d53c26dd9692c13eb8cc712';

/// Provider that calculates stock status for a product.
///
/// Handles both lot-tracked and non-lot-tracked products.
/// For lot-tracked products, sums all lot quantities to determine stock status.

final class PosProductStockFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProductStatus>, Product> {
  PosProductStockFamily._()
    : super(
        retry: null,
        name: r'posProductStockProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that calculates stock status for a product.
  ///
  /// Handles both lot-tracked and non-lot-tracked products.
  /// For lot-tracked products, sums all lot quantities to determine stock status.

  PosProductStockProvider call(Product product) =>
      PosProductStockProvider._(argument: product, from: this);

  @override
  String toString() => r'posProductStockProvider';
}
