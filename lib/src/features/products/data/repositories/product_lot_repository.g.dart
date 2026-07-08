// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_lot_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the ProductLotRepository instance.

@ProviderFor(productLotRepository)
final productLotRepositoryProvider = ProductLotRepositoryProvider._();

/// Provides the ProductLotRepository instance.

final class ProductLotRepositoryProvider
    extends
        $FunctionalProvider<
          ProductLotRepository,
          ProductLotRepository,
          ProductLotRepository
        >
    with $Provider<ProductLotRepository> {
  /// Provides the ProductLotRepository instance.
  ProductLotRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productLotRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productLotRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductLotRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductLotRepository create(Ref ref) {
    return productLotRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductLotRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductLotRepository>(value),
    );
  }
}

String _$productLotRepositoryHash() =>
    r'7e70cdb5326bf22dbc42d373dacf6fdcc5621ab3';
