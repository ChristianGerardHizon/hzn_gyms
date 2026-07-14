// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and caches inventory report data (current stock snapshot).

@ProviderFor(inventoryReport)
final inventoryReportProvider = InventoryReportProvider._();

/// Fetches and caches inventory report data (current stock snapshot).

final class InventoryReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryReport>,
          InventoryReport,
          FutureOr<InventoryReport>
        >
    with $FutureModifier<InventoryReport>, $FutureProvider<InventoryReport> {
  /// Fetches and caches inventory report data (current stock snapshot).
  InventoryReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryReportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryReportHash();

  @$internal
  @override
  $FutureProviderElement<InventoryReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InventoryReport> create(Ref ref) {
    return inventoryReport(ref);
  }
}

String _$inventoryReportHash() => r'20871da83c69bd32f840323273c7c27e4fe592f0';
