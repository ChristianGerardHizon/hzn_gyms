/// Result of a product or lot quantity increment/decrement.
class StockQuantityChange {
  const StockQuantityChange({
    required this.oldValue,
    required this.newValue,
  });

  /// Quantity before the update.
  final num oldValue;

  /// Quantity after the update.
  final num newValue;

  num get delta => newValue - oldValue;
}
