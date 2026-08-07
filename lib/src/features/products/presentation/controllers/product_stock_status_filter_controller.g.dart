// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_stock_status_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected stock status for filtering the Products list.
///
/// `null` means All (no stock-status filter).

@ProviderFor(ProductStockStatusFilter)
final productStockStatusFilterProvider = ProductStockStatusFilterProvider._();

/// Selected stock status for filtering the Products list.
///
/// `null` means All (no stock-status filter).
final class ProductStockStatusFilterProvider
    extends $NotifierProvider<ProductStockStatusFilter, ProductStatus?> {
  /// Selected stock status for filtering the Products list.
  ///
  /// `null` means All (no stock-status filter).
  ProductStockStatusFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productStockStatusFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productStockStatusFilterHash();

  @$internal
  @override
  ProductStockStatusFilter create() => ProductStockStatusFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductStatus?>(value),
    );
  }
}

String _$productStockStatusFilterHash() =>
    r'7d6c41eb7a5f12da52030bd4d19ee5973ce6d8a2';

/// Selected stock status for filtering the Products list.
///
/// `null` means All (no stock-status filter).

abstract class _$ProductStockStatusFilter extends $Notifier<ProductStatus?> {
  ProductStatus? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProductStatus?, ProductStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductStatus?, ProductStatus?>,
              ProductStatus?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
