// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_adjustments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for product adjustments by product ID.

@ProviderFor(productAdjustments)
final productAdjustmentsProvider = ProductAdjustmentsFamily._();

/// Provider for product adjustments by product ID.

final class ProductAdjustmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductAdjustment>>,
          List<ProductAdjustment>,
          FutureOr<List<ProductAdjustment>>
        >
    with
        $FutureModifier<List<ProductAdjustment>>,
        $FutureProvider<List<ProductAdjustment>> {
  /// Provider for product adjustments by product ID.
  ProductAdjustmentsProvider._({
    required ProductAdjustmentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productAdjustmentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productAdjustmentsHash();

  @override
  String toString() {
    return r'productAdjustmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductAdjustment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductAdjustment>> create(Ref ref) {
    final argument = this.argument as String;
    return productAdjustments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductAdjustmentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productAdjustmentsHash() =>
    r'feadbc9031ad5a7f9b46c9572b22efeca5ea2f8b';

/// Provider for product adjustments by product ID.

final class ProductAdjustmentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProductAdjustment>>, String> {
  ProductAdjustmentsFamily._()
    : super(
        retry: null,
        name: r'productAdjustmentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for product adjustments by product ID.

  ProductAdjustmentsProvider call(String productId) =>
      ProductAdjustmentsProvider._(argument: productId, from: this);

  @override
  String toString() => r'productAdjustmentsProvider';
}

/// Controller for managing product adjustments list.

@ProviderFor(ProductAdjustmentsController)
final productAdjustmentsControllerProvider =
    ProductAdjustmentsControllerFamily._();

/// Controller for managing product adjustments list.
final class ProductAdjustmentsControllerProvider
    extends
        $AsyncNotifierProvider<
          ProductAdjustmentsController,
          List<ProductAdjustment>
        > {
  /// Controller for managing product adjustments list.
  ProductAdjustmentsControllerProvider._({
    required ProductAdjustmentsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productAdjustmentsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productAdjustmentsControllerHash();

  @override
  String toString() {
    return r'productAdjustmentsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductAdjustmentsController create() => ProductAdjustmentsController();

  @override
  bool operator ==(Object other) {
    return other is ProductAdjustmentsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productAdjustmentsControllerHash() =>
    r'755d0df3a9c3c5322afe27fdba3efe44b0fcc163';

/// Controller for managing product adjustments list.

final class ProductAdjustmentsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductAdjustmentsController,
          AsyncValue<List<ProductAdjustment>>,
          List<ProductAdjustment>,
          FutureOr<List<ProductAdjustment>>,
          String
        > {
  ProductAdjustmentsControllerFamily._()
    : super(
        retry: null,
        name: r'productAdjustmentsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing product adjustments list.

  ProductAdjustmentsControllerProvider call(String productId) =>
      ProductAdjustmentsControllerProvider._(argument: productId, from: this);

  @override
  String toString() => r'productAdjustmentsControllerProvider';
}

/// Controller for managing product adjustments list.

abstract class _$ProductAdjustmentsController
    extends $AsyncNotifier<List<ProductAdjustment>> {
  late final _$args = ref.$arg as String;
  String get productId => _$args;

  FutureOr<List<ProductAdjustment>> build(String productId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ProductAdjustment>>,
              List<ProductAdjustment>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ProductAdjustment>>,
                List<ProductAdjustment>
              >,
              AsyncValue<List<ProductAdjustment>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
