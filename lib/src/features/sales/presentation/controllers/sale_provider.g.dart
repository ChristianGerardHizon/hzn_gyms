// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching a single sale by ID.

@ProviderFor(sale)
final saleProvider = SaleFamily._();

/// Provider for fetching a single sale by ID.

final class SaleProvider
    extends $FunctionalProvider<AsyncValue<Sale?>, Sale?, FutureOr<Sale?>>
    with $FutureModifier<Sale?>, $FutureProvider<Sale?> {
  /// Provider for fetching a single sale by ID.
  SaleProvider._({
    required SaleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleHash();

  @override
  String toString() {
    return r'saleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Sale?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Sale?> create(Ref ref) {
    final argument = this.argument as String;
    return sale(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleHash() => r'f36729253ff62567b2d15e784782bb5ec0893704';

/// Provider for fetching a single sale by ID.

final class SaleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Sale?>, String> {
  SaleFamily._()
    : super(
        retry: null,
        name: r'saleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching a single sale by ID.

  SaleProvider call(String id) => SaleProvider._(argument: id, from: this);

  @override
  String toString() => r'saleProvider';
}
