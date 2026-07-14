// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the ProductCategoryRepository instance.

@ProviderFor(productCategoryRepository)
final productCategoryRepositoryProvider = ProductCategoryRepositoryProvider._();

/// Provides the ProductCategoryRepository instance.

final class ProductCategoryRepositoryProvider
    extends
        $FunctionalProvider<
          ProductCategoryRepository,
          ProductCategoryRepository,
          ProductCategoryRepository
        >
    with $Provider<ProductCategoryRepository> {
  /// Provides the ProductCategoryRepository instance.
  ProductCategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productCategoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productCategoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductCategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductCategoryRepository create(Ref ref) {
    return productCategoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductCategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductCategoryRepository>(value),
    );
  }
}

String _$productCategoryRepositoryHash() =>
    r'2945240957394b7502f8cc99229730b4bc6c6f3a';
