// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_alerts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides comprehensive inventory alerts using optimized SQL views.
///
/// This provider queries 4 separate views in parallel:
/// - vw_low_stock_products (non-lot-tracked)
/// - vw_low_stock_lot_products (lot-tracked)
/// - vw_expired_lots
/// - vw_near_expiration_lots
///
/// Low-stock view rows are split into low stock (qty > 0, ≤ threshold) and
/// out of stock (qty ≤ 0).

@ProviderFor(inventoryAlertsSummary)
final inventoryAlertsSummaryProvider = InventoryAlertsSummaryProvider._();

/// Provides comprehensive inventory alerts using optimized SQL views.
///
/// This provider queries 4 separate views in parallel:
/// - vw_low_stock_products (non-lot-tracked)
/// - vw_low_stock_lot_products (lot-tracked)
/// - vw_expired_lots
/// - vw_near_expiration_lots
///
/// Low-stock view rows are split into low stock (qty > 0, ≤ threshold) and
/// out of stock (qty ≤ 0).

final class InventoryAlertsSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryAlertsSummary>,
          InventoryAlertsSummary,
          FutureOr<InventoryAlertsSummary>
        >
    with
        $FutureModifier<InventoryAlertsSummary>,
        $FutureProvider<InventoryAlertsSummary> {
  /// Provides comprehensive inventory alerts using optimized SQL views.
  ///
  /// This provider queries 4 separate views in parallel:
  /// - vw_low_stock_products (non-lot-tracked)
  /// - vw_low_stock_lot_products (lot-tracked)
  /// - vw_expired_lots
  /// - vw_near_expiration_lots
  ///
  /// Low-stock view rows are split into low stock (qty > 0, ≤ threshold) and
  /// out of stock (qty ≤ 0).
  InventoryAlertsSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryAlertsSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryAlertsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<InventoryAlertsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InventoryAlertsSummary> create(Ref ref) {
    return inventoryAlertsSummary(ref);
  }
}

String _$inventoryAlertsSummaryHash() =>
    r'bb501d45e367a2a7218a6f2ac22ffdf789643584';

/// Count of low stock products (qty > 0 and ≤ threshold).

@ProviderFor(lowStockAlertsCount)
final lowStockAlertsCountProvider = LowStockAlertsCountProvider._();

/// Count of low stock products (qty > 0 and ≤ threshold).

final class LowStockAlertsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of low stock products (qty > 0 and ≤ threshold).
  LowStockAlertsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lowStockAlertsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lowStockAlertsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return lowStockAlertsCount(ref);
  }
}

String _$lowStockAlertsCountHash() =>
    r'275864ab3141ee936764ce35024ac36993d0ffda';

/// Count of out-of-stock products (qty ≤ 0).

@ProviderFor(outOfStockAlertsCount)
final outOfStockAlertsCountProvider = OutOfStockAlertsCountProvider._();

/// Count of out-of-stock products (qty ≤ 0).

final class OutOfStockAlertsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of out-of-stock products (qty ≤ 0).
  OutOfStockAlertsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outOfStockAlertsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outOfStockAlertsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return outOfStockAlertsCount(ref);
  }
}

String _$outOfStockAlertsCountHash() =>
    r'eb450b9afa43eb6d2ac637129b44cbd7c99ea436';

/// Count of products/lots near expiration.

@ProviderFor(nearExpirationAlertsCount)
final nearExpirationAlertsCountProvider = NearExpirationAlertsCountProvider._();

/// Count of products/lots near expiration.

final class NearExpirationAlertsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of products/lots near expiration.
  NearExpirationAlertsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearExpirationAlertsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearExpirationAlertsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return nearExpirationAlertsCount(ref);
  }
}

String _$nearExpirationAlertsCountHash() =>
    r'06cf3c4166e64e7cb57cadb51ba3217bc0b73cd4';

/// Count of expired products/lots.

@ProviderFor(expiredAlertsCount)
final expiredAlertsCountProvider = ExpiredAlertsCountProvider._();

/// Count of expired products/lots.

final class ExpiredAlertsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of expired products/lots.
  ExpiredAlertsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expiredAlertsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expiredAlertsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return expiredAlertsCount(ref);
  }
}

String _$expiredAlertsCountHash() =>
    r'3c472626dd37ad757bb25f6db966994475668bef';

/// List of low stock alerts for display.

@ProviderFor(lowStockAlerts)
final lowStockAlertsProvider = LowStockAlertsProvider._();

/// List of low stock alerts for display.

final class LowStockAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryAlert>>,
          List<InventoryAlert>,
          FutureOr<List<InventoryAlert>>
        >
    with
        $FutureModifier<List<InventoryAlert>>,
        $FutureProvider<List<InventoryAlert>> {
  /// List of low stock alerts for display.
  LowStockAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lowStockAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lowStockAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<InventoryAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryAlert>> create(Ref ref) {
    return lowStockAlerts(ref);
  }
}

String _$lowStockAlertsHash() => r'08867d682ceec28dc0a0d5357aaa332b28e15c6c';

/// List of out-of-stock alerts for display.

@ProviderFor(outOfStockAlerts)
final outOfStockAlertsProvider = OutOfStockAlertsProvider._();

/// List of out-of-stock alerts for display.

final class OutOfStockAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryAlert>>,
          List<InventoryAlert>,
          FutureOr<List<InventoryAlert>>
        >
    with
        $FutureModifier<List<InventoryAlert>>,
        $FutureProvider<List<InventoryAlert>> {
  /// List of out-of-stock alerts for display.
  OutOfStockAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outOfStockAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outOfStockAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<InventoryAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryAlert>> create(Ref ref) {
    return outOfStockAlerts(ref);
  }
}

String _$outOfStockAlertsHash() => r'151860dae6d9f8f392ebf7a40facdd2f58a6232a';

/// List of near expiration alerts for display.

@ProviderFor(nearExpirationAlerts)
final nearExpirationAlertsProvider = NearExpirationAlertsProvider._();

/// List of near expiration alerts for display.

final class NearExpirationAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryAlert>>,
          List<InventoryAlert>,
          FutureOr<List<InventoryAlert>>
        >
    with
        $FutureModifier<List<InventoryAlert>>,
        $FutureProvider<List<InventoryAlert>> {
  /// List of near expiration alerts for display.
  NearExpirationAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearExpirationAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearExpirationAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<InventoryAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryAlert>> create(Ref ref) {
    return nearExpirationAlerts(ref);
  }
}

String _$nearExpirationAlertsHash() =>
    r'f6c003fba125bb40a3a43b434bb5f413f9200cfb';

/// List of expired alerts for display.

@ProviderFor(expiredAlerts)
final expiredAlertsProvider = ExpiredAlertsProvider._();

/// List of expired alerts for display.

final class ExpiredAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryAlert>>,
          List<InventoryAlert>,
          FutureOr<List<InventoryAlert>>
        >
    with
        $FutureModifier<List<InventoryAlert>>,
        $FutureProvider<List<InventoryAlert>> {
  /// List of expired alerts for display.
  ExpiredAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expiredAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expiredAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<InventoryAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryAlert>> create(Ref ref) {
    return expiredAlerts(ref);
  }
}

String _$expiredAlertsHash() => r'95354e5092991f137b32bcc494701d0959226bc4';
