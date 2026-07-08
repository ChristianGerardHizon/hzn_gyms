// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_sales_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing paginated sales list.

@ProviderFor(PaginatedSalesController)
final paginatedSalesControllerProvider = PaginatedSalesControllerProvider._();

/// Controller for managing paginated sales list.
final class PaginatedSalesControllerProvider
    extends
        $AsyncNotifierProvider<PaginatedSalesController, PaginatedState<Sale>> {
  /// Controller for managing paginated sales list.
  PaginatedSalesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSalesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSalesControllerHash();

  @$internal
  @override
  PaginatedSalesController create() => PaginatedSalesController();
}

String _$paginatedSalesControllerHash() =>
    r'85cbab7f2e59f281db91f29c4f09e464248e87db';

/// Controller for managing paginated sales list.

abstract class _$PaginatedSalesController
    extends $AsyncNotifier<PaginatedState<Sale>> {
  FutureOr<PaginatedState<Sale>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedState<Sale>>, PaginatedState<Sale>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<Sale>>,
                PaginatedState<Sale>
              >,
              AsyncValue<PaginatedState<Sale>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
