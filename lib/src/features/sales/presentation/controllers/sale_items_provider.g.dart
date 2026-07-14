// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching sale items by sale ID.

@ProviderFor(saleItems)
final saleItemsProvider = SaleItemsFamily._();

/// Provider for fetching sale items by sale ID.

final class SaleItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SaleItem>>,
          List<SaleItem>,
          FutureOr<List<SaleItem>>
        >
    with $FutureModifier<List<SaleItem>>, $FutureProvider<List<SaleItem>> {
  /// Provider for fetching sale items by sale ID.
  SaleItemsProvider._({
    required SaleItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleItemsHash();

  @override
  String toString() {
    return r'saleItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SaleItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SaleItem>> create(Ref ref) {
    final argument = this.argument as String;
    return saleItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleItemsHash() => r'6743a1b1941a85e6cc1a6619842676fe5a7109b7';

/// Provider for fetching sale items by sale ID.

final class SaleItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SaleItem>>, String> {
  SaleItemsFamily._()
    : super(
        retry: null,
        name: r'saleItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching sale items by sale ID.

  SaleItemsProvider call(String saleId) =>
      SaleItemsProvider._(argument: saleId, from: this);

  @override
  String toString() => r'saleItemsProvider';
}
