// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thermal_print_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for thermal printing operations.

@ProviderFor(ThermalPrintService)
final thermalPrintServiceProvider = ThermalPrintServiceProvider._();

/// Service for thermal printing operations.
final class ThermalPrintServiceProvider
    extends $AsyncNotifierProvider<ThermalPrintService, void> {
  /// Service for thermal printing operations.
  ThermalPrintServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thermalPrintServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thermalPrintServiceHash();

  @$internal
  @override
  ThermalPrintService create() => ThermalPrintService();
}

String _$thermalPrintServiceHash() =>
    r'dd48f3b0f58d7e86e080fa22241920fca41095fa';

/// Service for thermal printing operations.

abstract class _$ThermalPrintService extends $AsyncNotifier<void> {
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
