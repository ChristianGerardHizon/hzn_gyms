// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for all product categories.

@ProviderFor(productCategories)
final productCategoriesProvider = ProductCategoriesProvider._();

/// Provider for all product categories.

final class ProductCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductCategory>>,
          List<ProductCategory>,
          FutureOr<List<ProductCategory>>
        >
    with
        $FutureModifier<List<ProductCategory>>,
        $FutureProvider<List<ProductCategory>> {
  /// Provider for all product categories.
  ProductCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ProductCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductCategory>> create(Ref ref) {
    return productCategories(ref);
  }
}

String _$productCategoriesHash() => r'7d29979c42a984bb0eb6bb0d8d1f3379e6fe682a';

/// Provider for product categories by parent ID.

@ProviderFor(productCategoriesByParent)
final productCategoriesByParentProvider = ProductCategoriesByParentFamily._();

/// Provider for product categories by parent ID.

final class ProductCategoriesByParentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductCategory>>,
          List<ProductCategory>,
          FutureOr<List<ProductCategory>>
        >
    with
        $FutureModifier<List<ProductCategory>>,
        $FutureProvider<List<ProductCategory>> {
  /// Provider for product categories by parent ID.
  ProductCategoriesByParentProvider._({
    required ProductCategoriesByParentFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'productCategoriesByParentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productCategoriesByParentHash();

  @override
  String toString() {
    return r'productCategoriesByParentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductCategory>> create(Ref ref) {
    final argument = this.argument as String?;
    return productCategoriesByParent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductCategoriesByParentProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productCategoriesByParentHash() =>
    r'2b0f3e9f98c458346edc5c860d4ac09ac8a8909d';

/// Provider for product categories by parent ID.

final class ProductCategoriesByParentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProductCategory>>, String?> {
  ProductCategoriesByParentFamily._()
    : super(
        retry: null,
        name: r'productCategoriesByParentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for product categories by parent ID.

  ProductCategoriesByParentProvider call(String? parentId) =>
      ProductCategoriesByParentProvider._(argument: parentId, from: this);

  @override
  String toString() => r'productCategoriesByParentProvider';
}
