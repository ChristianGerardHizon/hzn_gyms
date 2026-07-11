// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_sort_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for managing product list sort configuration.

@ProviderFor(ProductSortController)
final productSortControllerProvider = ProductSortControllerProvider._();

/// Provider for managing product list sort configuration.
final class ProductSortControllerProvider
    extends $NotifierProvider<ProductSortController, SortConfig> {
  /// Provider for managing product list sort configuration.
  ProductSortControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productSortControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productSortControllerHash();

  @$internal
  @override
  ProductSortController create() => ProductSortController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SortConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SortConfig>(value),
    );
  }
}

String _$productSortControllerHash() =>
    r'98734f78b0f5bb15a9b49fb7770098d3d97e1f1d';

/// Provider for managing product list sort configuration.

abstract class _$ProductSortController extends $Notifier<SortConfig> {
  SortConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SortConfig, SortConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SortConfig, SortConfig>,
              SortConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
