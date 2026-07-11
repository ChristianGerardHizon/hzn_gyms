// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and provides inventory report data.
/// Note: Inventory report doesn't use date filtering - it shows current state.

@ProviderFor(inventoryReport)
final inventoryReportProvider = InventoryReportProvider._();

/// Fetches and provides inventory report data.
/// Note: Inventory report doesn't use date filtering - it shows current state.

final class InventoryReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryReport>,
          InventoryReport,
          FutureOr<InventoryReport>
        >
    with $FutureModifier<InventoryReport>, $FutureProvider<InventoryReport> {
  /// Fetches and provides inventory report data.
  /// Note: Inventory report doesn't use date filtering - it shows current state.
  InventoryReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryReportProvider',
        isAutoDispose: true,
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

String _$inventoryReportHash() => r'd5f021b7a5a38457dc2a506cc3fa26c5be626f61';
