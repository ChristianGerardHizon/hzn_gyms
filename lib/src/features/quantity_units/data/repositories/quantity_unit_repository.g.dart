// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_unit_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the QuantityUnitRepository instance.

@ProviderFor(quantityUnitRepository)
final quantityUnitRepositoryProvider = QuantityUnitRepositoryProvider._();

/// Provides the QuantityUnitRepository instance.

final class QuantityUnitRepositoryProvider
    extends
        $FunctionalProvider<
          QuantityUnitRepository,
          QuantityUnitRepository,
          QuantityUnitRepository
        >
    with $Provider<QuantityUnitRepository> {
  /// Provides the QuantityUnitRepository instance.
  QuantityUnitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quantityUnitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quantityUnitRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuantityUnitRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuantityUnitRepository create(Ref ref) {
    return quantityUnitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuantityUnitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuantityUnitRepository>(value),
    );
  }
}

String _$quantityUnitRepositoryHash() =>
    r'715cb8c3a2c42a9a8f25aba6e383d1a2d58ea163';
