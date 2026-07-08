// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_lots_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for product lots by product ID.

@ProviderFor(productLots)
final productLotsProvider = ProductLotsFamily._();

/// Provider for product lots by product ID.

final class ProductLotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductLot>>,
          List<ProductLot>,
          FutureOr<List<ProductLot>>
        >
    with $FutureModifier<List<ProductLot>>, $FutureProvider<List<ProductLot>> {
  /// Provider for product lots by product ID.
  ProductLotsProvider._({
    required ProductLotsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productLotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productLotsHash();

  @override
  String toString() {
    return r'productLotsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductLot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductLot>> create(Ref ref) {
    final argument = this.argument as String;
    return productLots(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductLotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productLotsHash() => r'9db794f3ab0af6c36718adc7a9ccb8a2dd2e2bcf';

/// Provider for product lots by product ID.

final class ProductLotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProductLot>>, String> {
  ProductLotsFamily._()
    : super(
        retry: null,
        name: r'productLotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for product lots by product ID.

  ProductLotsProvider call(String productId) =>
      ProductLotsProvider._(argument: productId, from: this);

  @override
  String toString() => r'productLotsProvider';
}

/// Provider for total quantity of lots for a product.

@ProviderFor(productLotsTotal)
final productLotsTotalProvider = ProductLotsTotalFamily._();

/// Provider for total quantity of lots for a product.

final class ProductLotsTotalProvider
    extends $FunctionalProvider<AsyncValue<num>, num, FutureOr<num>>
    with $FutureModifier<num>, $FutureProvider<num> {
  /// Provider for total quantity of lots for a product.
  ProductLotsTotalProvider._({
    required ProductLotsTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productLotsTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productLotsTotalHash();

  @override
  String toString() {
    return r'productLotsTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<num> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<num> create(Ref ref) {
    final argument = this.argument as String;
    return productLotsTotal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductLotsTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productLotsTotalHash() => r'0aa175642ba72676f97b36f7e524a88e80515b6f';

/// Provider for total quantity of lots for a product.

final class ProductLotsTotalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<num>, String> {
  ProductLotsTotalFamily._()
    : super(
        retry: null,
        name: r'productLotsTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for total quantity of lots for a product.

  ProductLotsTotalProvider call(String productId) =>
      ProductLotsTotalProvider._(argument: productId, from: this);

  @override
  String toString() => r'productLotsTotalProvider';
}

/// Controller for managing product lots.

@ProviderFor(ProductLotsController)
final productLotsControllerProvider = ProductLotsControllerFamily._();

/// Controller for managing product lots.
final class ProductLotsControllerProvider
    extends $AsyncNotifierProvider<ProductLotsController, List<ProductLot>> {
  /// Controller for managing product lots.
  ProductLotsControllerProvider._({
    required ProductLotsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productLotsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productLotsControllerHash();

  @override
  String toString() {
    return r'productLotsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductLotsController create() => ProductLotsController();

  @override
  bool operator ==(Object other) {
    return other is ProductLotsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productLotsControllerHash() =>
    r'854a3ce5637125ad9de3e5f9c3140cfd7eb3130c';

/// Controller for managing product lots.

final class ProductLotsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductLotsController,
          AsyncValue<List<ProductLot>>,
          List<ProductLot>,
          FutureOr<List<ProductLot>>,
          String
        > {
  ProductLotsControllerFamily._()
    : super(
        retry: null,
        name: r'productLotsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing product lots.

  ProductLotsControllerProvider call(String productId) =>
      ProductLotsControllerProvider._(argument: productId, from: this);

  @override
  String toString() => r'productLotsControllerProvider';
}

/// Controller for managing product lots.

abstract class _$ProductLotsController
    extends $AsyncNotifier<List<ProductLot>> {
  late final _$args = ref.$arg as String;
  String get productId => _$args;

  FutureOr<List<ProductLot>> build(String productId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ProductLot>>, List<ProductLot>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProductLot>>, List<ProductLot>>,
              AsyncValue<List<ProductLot>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
