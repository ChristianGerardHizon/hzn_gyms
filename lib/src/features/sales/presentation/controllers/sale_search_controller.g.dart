// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for sale search query state.

@ProviderFor(SaleSearchQuery)
final saleSearchQueryProvider = SaleSearchQueryProvider._();

/// Provider for sale search query state.
final class SaleSearchQueryProvider
    extends $NotifierProvider<SaleSearchQuery, String> {
  /// Provider for sale search query state.
  SaleSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleSearchQueryHash();

  @$internal
  @override
  SaleSearchQuery create() => SaleSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$saleSearchQueryHash() => r'5fdf399931f824994266e9d4433d2f9e92e4198c';

/// Provider for sale search query state.

abstract class _$SaleSearchQuery extends $Notifier<String> {
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

/// Provider for managing which fields are included in sale search.

@ProviderFor(SaleSearchFields)
final saleSearchFieldsProvider = SaleSearchFieldsProvider._();

/// Provider for managing which fields are included in sale search.
final class SaleSearchFieldsProvider
    extends $NotifierProvider<SaleSearchFields, Set<String>> {
  /// Provider for managing which fields are included in sale search.
  SaleSearchFieldsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleSearchFieldsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleSearchFieldsHash();

  @$internal
  @override
  SaleSearchFields create() => SaleSearchFields();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$saleSearchFieldsHash() => r'59827197e8210e382d6fed9a0e2dfb9001b339f1';

/// Provider for managing which fields are included in sale search.

abstract class _$SaleSearchFields extends $Notifier<Set<String>> {
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

/// Provider for which sale status groups are included in the list filter.

@ProviderFor(SaleStatusFilters)
final saleStatusFiltersProvider = SaleStatusFiltersProvider._();

/// Provider for which sale status groups are included in the list filter.
final class SaleStatusFiltersProvider
    extends $NotifierProvider<SaleStatusFilters, Set<String>> {
  /// Provider for which sale status groups are included in the list filter.
  SaleStatusFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleStatusFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleStatusFiltersHash();

  @$internal
  @override
  SaleStatusFilters create() => SaleStatusFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$saleStatusFiltersHash() => r'7794ef752f93ff01767aadde0e53a364ef43b686';

/// Provider for which sale status groups are included in the list filter.

abstract class _$SaleStatusFilters extends $Notifier<Set<String>> {
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
