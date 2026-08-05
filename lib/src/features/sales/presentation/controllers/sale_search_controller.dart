import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/sale_status_filter.dart';

part 'sale_search_controller.g.dart';

/// Available search fields for sales.
const saleSearchableFields = [
  'receiptNumber',
  'descriptor',
  'customerName',
  'paymentRef',
  'notes',
];

/// Default fields selected for sale search.
const defaultSaleSearchFields = {
  'receiptNumber',
  'descriptor',
  'customerName',
};

/// Provider for sale search query state.
@riverpod
class SaleSearchQuery extends _$SaleSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for managing which fields are included in sale search.
@riverpod
class SaleSearchFields extends _$SaleSearchFields {
  @override
  Set<String> build() => Set<String>.from(defaultSaleSearchFields);

  void toggleField(String field) {
    if (state.contains(field)) {
      // Prevent removing if it's the last field
      if (state.length <= 1) return;
      state = {...state}..remove(field);
    } else {
      state = {...state, field};
    }
  }

  void reset() {
    state = Set<String>.from(defaultSaleSearchFields);
  }

  void setFields(Set<String> fields) {
    // Ensure at least one field is selected
    if (fields.isEmpty) {
      state = Set<String>.from(defaultSaleSearchFields);
    } else {
      state = Set<String>.from(fields);
    }
  }
}

/// Provider for which sale status groups are included in the list filter.
@riverpod
class SaleStatusFilters extends _$SaleStatusFilters {
  @override
  Set<String> build() => Set<String>.from(defaultSaleStatusFilters);

  void toggleStatus(String status) {
    if (state.contains(status)) {
      if (state.length <= 1) return;
      state = {...state}..remove(status);
    } else {
      state = {...state, status};
    }
  }

  void reset() {
    state = Set<String>.from(defaultSaleStatusFilters);
  }

  void setStatuses(Set<String> statuses) {
    if (statuses.isEmpty) {
      state = Set<String>.from(defaultSaleStatusFilters);
    } else {
      state = Set<String>.from(statuses);
    }
  }
}
