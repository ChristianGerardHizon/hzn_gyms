// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_configs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing printer configuration list state.
///
/// Provides methods for fetching and CRUD operations on printer configs.

@ProviderFor(PrinterConfigsController)
final printerConfigsControllerProvider = PrinterConfigsControllerProvider._();

/// Controller for managing printer configuration list state.
///
/// Provides methods for fetching and CRUD operations on printer configs.
final class PrinterConfigsControllerProvider
    extends
        $AsyncNotifierProvider<PrinterConfigsController, List<PrinterConfig>> {
  /// Controller for managing printer configuration list state.
  ///
  /// Provides methods for fetching and CRUD operations on printer configs.
  PrinterConfigsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printerConfigsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printerConfigsControllerHash();

  @$internal
  @override
  PrinterConfigsController create() => PrinterConfigsController();
}

String _$printerConfigsControllerHash() =>
    r'd39e06de8e80adc3020c119471b55e4986cd39a7';

/// Controller for managing printer configuration list state.
///
/// Provides methods for fetching and CRUD operations on printer configs.

abstract class _$PrinterConfigsController
    extends $AsyncNotifier<List<PrinterConfig>> {
  FutureOr<List<PrinterConfig>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PrinterConfig>>, List<PrinterConfig>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PrinterConfig>>, List<PrinterConfig>>,
              AsyncValue<List<PrinterConfig>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
