// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_categories_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing product category list state.
///
/// Provides methods for fetching and CRUD operations on product categories.

@ProviderFor(ProductCategoriesController)
final productCategoriesControllerProvider =
    ProductCategoriesControllerProvider._();

/// Controller for managing product category list state.
///
/// Provides methods for fetching and CRUD operations on product categories.
final class ProductCategoriesControllerProvider
    extends
        $AsyncNotifierProvider<
          ProductCategoriesController,
          List<ProductCategory>
        > {
  /// Controller for managing product category list state.
  ///
  /// Provides methods for fetching and CRUD operations on product categories.
  ProductCategoriesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productCategoriesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productCategoriesControllerHash();

  @$internal
  @override
  ProductCategoriesController create() => ProductCategoriesController();
}

String _$productCategoriesControllerHash() =>
    r'4b4957a1b8036d22db4504615b34be2585a85ab5';

/// Controller for managing product category list state.
///
/// Provides methods for fetching and CRUD operations on product categories.

abstract class _$ProductCategoriesController
    extends $AsyncNotifier<List<ProductCategory>> {
  FutureOr<List<ProductCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ProductCategory>>, List<ProductCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ProductCategory>>,
                List<ProductCategory>
              >,
              AsyncValue<List<ProductCategory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
