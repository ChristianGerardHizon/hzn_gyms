// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_units_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing quantity units list in settings.

@ProviderFor(QuantityUnitsController)
final quantityUnitsControllerProvider = QuantityUnitsControllerProvider._();

/// Controller for managing quantity units list in settings.
final class QuantityUnitsControllerProvider
    extends
        $AsyncNotifierProvider<QuantityUnitsController, List<QuantityUnit>> {
  /// Controller for managing quantity units list in settings.
  QuantityUnitsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quantityUnitsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quantityUnitsControllerHash();

  @$internal
  @override
  QuantityUnitsController create() => QuantityUnitsController();
}

String _$quantityUnitsControllerHash() =>
    r'faf392b77ba3d54745f09caed9c3314a3a4738c3';

/// Controller for managing quantity units list in settings.

abstract class _$QuantityUnitsController
    extends $AsyncNotifier<List<QuantityUnit>> {
  FutureOr<List<QuantityUnit>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<QuantityUnit>>, List<QuantityUnit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<QuantityUnit>>, List<QuantityUnit>>,
              AsyncValue<List<QuantityUnit>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
