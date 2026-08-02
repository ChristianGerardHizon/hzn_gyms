/// Enum for product detail page tabs.
enum ProductTab {
  overview,
  details,
  stock,
  adjustments,
  sales;

  /// Parse a tab name string to ProductTab, defaults to overview.
  static ProductTab fromString(String? name) {
    return ProductTab.values.firstWhere(
      (tab) => tab.name == name,
      orElse: () => ProductTab.overview,
    );
  }
}
