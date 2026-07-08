// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_kpi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of products that are near expiration (within 30 days).
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.

@ProviderFor(productsNearExpirationCount)
final productsNearExpirationCountProvider =
    ProductsNearExpirationCountProvider._();

/// Count of products that are near expiration (within 30 days).
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.

final class ProductsNearExpirationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of products that are near expiration (within 30 days).
  /// Delegates to the unified inventory alerts controller for both lot-tracked
  /// and non-lot-tracked products.
  ProductsNearExpirationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsNearExpirationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsNearExpirationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return productsNearExpirationCount(ref);
  }
}

String _$productsNearExpirationCountHash() =>
    r'6d033a9d0938b4888d7b09f12db6c15b5e881080';

/// Count of products that are expired.
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.

@ProviderFor(productsExpiredCount)
final productsExpiredCountProvider = ProductsExpiredCountProvider._();

/// Count of products that are expired.
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.

final class ProductsExpiredCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of products that are expired.
  /// Delegates to the unified inventory alerts controller for both lot-tracked
  /// and non-lot-tracked products.
  ProductsExpiredCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsExpiredCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsExpiredCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return productsExpiredCount(ref);
  }
}

String _$productsExpiredCountHash() =>
    r'9ba10f936908802e3f98d8a8f5440349f071783f';

/// Count of products with low stock.
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.

@ProviderFor(lowStockProductsCount)
final lowStockProductsCountProvider = LowStockProductsCountProvider._();

/// Count of products with low stock.
/// Delegates to the unified inventory alerts controller for both lot-tracked
/// and non-lot-tracked products.

final class LowStockProductsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of products with low stock.
  /// Delegates to the unified inventory alerts controller for both lot-tracked
  /// and non-lot-tracked products.
  LowStockProductsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lowStockProductsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lowStockProductsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return lowStockProductsCount(ref);
  }
}

String _$lowStockProductsCountHash() =>
    r'ab8d76053c11fe2fe42d1cab369a1ccaae8a4c3b';
