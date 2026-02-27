// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CartController)
final cartControllerProvider = CartControllerProvider._();

final class CartControllerProvider
    extends $AsyncNotifierProvider<CartController, CartState> {
  CartControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartControllerHash();

  @$internal
  @override
  CartController create() => CartController();
}

String _$cartControllerHash() => r'd532a6be31ebc4808b42c3f837eadb1faa40e3f5';

abstract class _$CartController extends $AsyncNotifier<CartState> {
  FutureOr<CartState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CartState>, CartState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CartState>, CartState>,
        AsyncValue<CartState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for cart total.

@ProviderFor(cartTotal)
final cartTotalProvider = CartTotalProvider._();

/// Provider for cart total.

final class CartTotalProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Provider for cart total.
  CartTotalProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartTotalProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return cartTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$cartTotalHash() => r'f9e7b10f0176904bea5f6cdbca3af1f7c123c4f9';

/// Provider for cart product items.

@ProviderFor(cartItems)
final cartItemsProvider = CartItemsProvider._();

/// Provider for cart product items.

final class CartItemsProvider
    extends $FunctionalProvider<List<CartItem>, List<CartItem>, List<CartItem>>
    with $Provider<List<CartItem>> {
  /// Provider for cart product items.
  CartItemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartItemsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartItemsHash();

  @$internal
  @override
  $ProviderElement<List<CartItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CartItem> create(Ref ref) {
    return cartItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItem>>(value),
    );
  }
}

String _$cartItemsHash() => r'fbdc81b5c3d757873612c7d60708a85bfa210b17';
