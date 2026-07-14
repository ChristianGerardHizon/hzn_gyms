// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for product search query state.

@ProviderFor(ProductSearchQuery)
final productSearchQueryProvider = ProductSearchQueryProvider._();

/// Provider for product search query state.
final class ProductSearchQueryProvider
    extends $NotifierProvider<ProductSearchQuery, String> {
  /// Provider for product search query state.
  ProductSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productSearchQueryHash();

  @$internal
  @override
  ProductSearchQuery create() => ProductSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$productSearchQueryHash() =>
    r'b282fa8a6f269c0054fee5404f527ce5432c427e';

/// Provider for product search query state.

abstract class _$ProductSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for managing which fields are included in product search.

@ProviderFor(ProductSearchFields)
final productSearchFieldsProvider = ProductSearchFieldsProvider._();

/// Provider for managing which fields are included in product search.
final class ProductSearchFieldsProvider
    extends $NotifierProvider<ProductSearchFields, Set<String>> {
  /// Provider for managing which fields are included in product search.
  ProductSearchFieldsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productSearchFieldsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productSearchFieldsHash();

  @$internal
  @override
  ProductSearchFields create() => ProductSearchFields();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$productSearchFieldsHash() =>
    r'1e9af978e039c4e54c6c43c78485ea49b43e3fb2';

/// Provider for managing which fields are included in product search.

abstract class _$ProductSearchFields extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
