// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for handling stock adjustment operations.
///
/// Provides methods to adjust product and lot quantities with
/// automatic adjustment record creation for audit trail.

@ProviderFor(StockAdjustmentController)
final stockAdjustmentControllerProvider = StockAdjustmentControllerProvider._();

/// Controller for handling stock adjustment operations.
///
/// Provides methods to adjust product and lot quantities with
/// automatic adjustment record creation for audit trail.
final class StockAdjustmentControllerProvider
    extends $AsyncNotifierProvider<StockAdjustmentController, void> {
  /// Controller for handling stock adjustment operations.
  ///
  /// Provides methods to adjust product and lot quantities with
  /// automatic adjustment record creation for audit trail.
  StockAdjustmentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockAdjustmentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockAdjustmentControllerHash();

  @$internal
  @override
  StockAdjustmentController create() => StockAdjustmentController();
}

String _$stockAdjustmentControllerHash() =>
    r'c86506be124463db0d75143767df8696efe23273';

/// Controller for handling stock adjustment operations.
///
/// Provides methods to adjust product and lot quantities with
/// automatic adjustment record creation for audit trail.

abstract class _$StockAdjustmentController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
