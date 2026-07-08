// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_products_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing paginated products list.

@ProviderFor(PaginatedProductsController)
final paginatedProductsControllerProvider =
    PaginatedProductsControllerProvider._();

/// Controller for managing paginated products list.
final class PaginatedProductsControllerProvider
    extends
        $AsyncNotifierProvider<
          PaginatedProductsController,
          PaginatedState<Product>
        > {
  /// Controller for managing paginated products list.
  PaginatedProductsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedProductsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedProductsControllerHash();

  @$internal
  @override
  PaginatedProductsController create() => PaginatedProductsController();
}

String _$paginatedProductsControllerHash() =>
    r'49bd90423cd59495e7eb0f2980a722d44d64e8bd';

/// Controller for managing paginated products list.

abstract class _$PaginatedProductsController
    extends $AsyncNotifier<PaginatedState<Product>> {
  FutureOr<PaginatedState<Product>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedState<Product>>,
              PaginatedState<Product>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<Product>>,
                PaginatedState<Product>
              >,
              AsyncValue<PaginatedState<Product>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
