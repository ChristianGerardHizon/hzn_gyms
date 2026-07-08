// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_units_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides all quantity units.

@ProviderFor(quantityUnits)
final quantityUnitsProvider = QuantityUnitsProvider._();

/// Provides all quantity units.

final class QuantityUnitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuantityUnit>>,
          List<QuantityUnit>,
          FutureOr<List<QuantityUnit>>
        >
    with
        $FutureModifier<List<QuantityUnit>>,
        $FutureProvider<List<QuantityUnit>> {
  /// Provides all quantity units.
  QuantityUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quantityUnitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quantityUnitsHash();

  @$internal
  @override
  $FutureProviderElement<List<QuantityUnit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuantityUnit>> create(Ref ref) {
    return quantityUnits(ref);
  }
}

String _$quantityUnitsHash() => r'6cd9f557deb62bdbebf622681da88153626c1a98';
