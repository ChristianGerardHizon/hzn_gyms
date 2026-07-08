// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_adjustment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the ProductAdjustmentRepository instance.

@ProviderFor(productAdjustmentRepository)
final productAdjustmentRepositoryProvider =
    ProductAdjustmentRepositoryProvider._();

/// Provides the ProductAdjustmentRepository instance.

final class ProductAdjustmentRepositoryProvider
    extends
        $FunctionalProvider<
          ProductAdjustmentRepository,
          ProductAdjustmentRepository,
          ProductAdjustmentRepository
        >
    with $Provider<ProductAdjustmentRepository> {
  /// Provides the ProductAdjustmentRepository instance.
  ProductAdjustmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productAdjustmentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productAdjustmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductAdjustmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductAdjustmentRepository create(Ref ref) {
    return productAdjustmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductAdjustmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductAdjustmentRepository>(value),
    );
  }
}

String _$productAdjustmentRepositoryHash() =>
    r'2f4ab0df49881f482b13f111f50418760a722e43';
