// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_selling_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Top 5 selling products (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
/// by product (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.

@ProviderFor(topSellingProducts)
final topSellingProductsProvider = TopSellingProductsProvider._();

/// Top 5 selling products (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
/// by product (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.

final class TopSellingProductsProvider extends $FunctionalProvider<
        AsyncValue<List<TopSellingItem>>,
        List<TopSellingItem>,
        FutureOr<List<TopSellingItem>>>
    with
        $FutureModifier<List<TopSellingItem>>,
        $FutureProvider<List<TopSellingItem>> {
  /// Top 5 selling products (all-time, aggregated from date-grouped view).
  ///
  /// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
  /// by product (since the view groups by date), sorts by revenue descending,
  /// and returns the top 5.
  TopSellingProductsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'topSellingProductsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$topSellingProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<TopSellingItem>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TopSellingItem>> create(Ref ref) {
    return topSellingProducts(ref);
  }
}

String _$topSellingProductsHash() =>
    r'f983b5508d2ca6c761179167ae1237d5df829773';
