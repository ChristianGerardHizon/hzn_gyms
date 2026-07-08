import 'package:csv/csv.dart';

import '../../../products/domain/product_category.dart';

/// A single parsed product entry from a CSV row.
class CsvProductEntry {
  CsvProductEntry({
    required this.name,
    this.categoryName,
    this.description,
    this.price = 0,
    this.isVariablePrice = false,
    this.trackStock = false,
    this.forSale = true,
    this.quantity,
    this.stockThreshold,
    this.isSelected = true,
  });

  final String name;
  final String? categoryName;
  final String? description;
  final num price;
  final bool isVariablePrice;
  final bool trackStock;
  final bool forSale;
  final num? quantity;
  final num? stockThreshold;

  /// Whether this entry is selected for import (toggled in review step).
  bool isSelected;
}

/// Result of parsing a CSV file.
class CsvParseResult {
  const CsvParseResult({
    required this.entries,
    required this.newCategoryNames,
    required this.existingCategoryNames,
    required this.warnings,
    required this.skippedRows,
  });

  final List<CsvProductEntry> entries;
  final Set<String> newCategoryNames;
  final Set<String> existingCategoryNames;
  final List<String> warnings;
  final int skippedRows;

  int get totalRows => entries.length + skippedRows;
  int get selectedCount => entries.where((e) => e.isSelected).length;
}

/// Service for parsing CSV files into product import data.
class CsvImportService {
  /// Parses CSV content and returns structured import data.
  ///
  /// [csvContent] is the raw CSV string.
  /// [existingCategories] is used to identify which categories already exist.
  CsvParseResult parse(
    String csvContent,
    List<ProductCategory> existingCategories,
  ) {
    List<List<dynamic>> rows;
    try {
      rows = csv.decode(csvContent);
    } catch (_) {
      rows = Csv(lineDelimiter: '\n').decode(csvContent);
    }

    if (rows.isEmpty) {
      return const CsvParseResult(
        entries: [],
        newCategoryNames: {},
        existingCategoryNames: {},
        warnings: ['CSV file is empty'],
        skippedRows: 0,
      );
    }

    // Parse header row
    final headers =
        rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final nameCol = _findColumn(headers, 'name');
    final categoryCol = _findColumn(headers, 'category');
    final descriptionCol = _findColumn(headers, 'description');
    final priceCol = _findColumn(headers, 'price');
    final trackStockCol = _findColumn(headers, 'track stock');
    final forSaleCol = _findColumn(headers, 'available for sale');
    final inStockCol = _findColumn(headers, 'in stock');
    final lowStockCol = _findColumn(headers, 'low stock');

    final warnings = <String>[];

    if (nameCol == null) {
      return CsvParseResult(
        entries: [],
        newCategoryNames: {},
        existingCategoryNames: {},
        warnings: ['Could not find "Name" column in CSV headers'],
        skippedRows: rows.length - 1,
      );
    }

    // Build existing category lookup (case-insensitive)
    final existingCategoryMap = <String, ProductCategory>{
      for (final cat in existingCategories) cat.name.toLowerCase(): cat,
    };

    final entries = <CsvProductEntry>[];
    final allCategoryNames = <String>{};
    var skippedRows = 0;

    // Process data rows (skip header)
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];

      final name = _getString(row, nameCol)?.trim();
      if (name == null || name.isEmpty) {
        skippedRows++;
        continue;
      }

      final categoryName = _getString(row, categoryCol)?.trim();
      if (categoryName != null && categoryName.isNotEmpty) {
        allCategoryNames.add(categoryName);
      }

      final rawPrice = _getString(row, priceCol)?.trim();
      final isVariable = rawPrice != null &&
          rawPrice.toLowerCase() == 'variable';
      final price = isVariable ? 0 : _parseNum(rawPrice);

      entries.add(CsvProductEntry(
        name: name,
        categoryName:
            categoryName != null && categoryName.isNotEmpty
                ? categoryName
                : null,
        description: _getString(row, descriptionCol)?.trim(),
        price: price,
        isVariablePrice: isVariable,
        trackStock: _parseYN(_getString(row, trackStockCol)),
        forSale: _parseYN(_getString(row, forSaleCol)),
        quantity: _parseNullableNum(_getString(row, inStockCol)),
        stockThreshold: _parseNullableNum(_getString(row, lowStockCol)),
      ));
    }

    // Determine new vs existing categories
    final newCategoryNames = <String>{};
    final existingCategoryNames = <String>{};

    for (final catName in allCategoryNames) {
      if (existingCategoryMap.containsKey(catName.toLowerCase())) {
        existingCategoryNames.add(catName);
      } else {
        newCategoryNames.add(catName);
      }
    }

    return CsvParseResult(
      entries: entries,
      newCategoryNames: newCategoryNames,
      existingCategoryNames: existingCategoryNames,
      warnings: warnings,
      skippedRows: skippedRows,
    );
  }

  /// Finds a column index by fuzzy matching the header.
  int? _findColumn(List<String> headers, String pattern) {
    final lowerPattern = pattern.toLowerCase();
    final index = headers.indexWhere(
      (h) => h.contains(lowerPattern),
    );
    return index >= 0 ? index : null;
  }

  String? _getString(List<dynamic> row, int? col) {
    if (col == null || col >= row.length) return null;
    final value = row[col];
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  num _parseNum(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    return num.tryParse(raw.replaceAll(',', '')) ?? 0;
  }

  num? _parseNullableNum(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return num.tryParse(raw.trim().replaceAll(',', ''));
  }

  bool _parseYN(String? raw) =>
      raw != null && raw.trim().toUpperCase() == 'Y';
}
