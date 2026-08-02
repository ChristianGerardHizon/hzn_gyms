import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_search_controller.g.dart';

/// Available search fields for products.
const productSearchableFields = [
  'name',
  'description',
  'category',
];

/// Default fields selected for product search.
const defaultProductSearchFields = {'name'};

/// Provider for product search query state.
@riverpod
class ProductSearchQuery extends _$ProductSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for managing which fields are included in product search.
@riverpod
class ProductSearchFields extends _$ProductSearchFields {
  @override
  Set<String> build() => Set<String>.from(defaultProductSearchFields);

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
    state = Set<String>.from(defaultProductSearchFields);
  }

  void setFields(Set<String> fields) {
    // Ensure at least one field is selected
    if (fields.isEmpty) {
      state = Set<String>.from(defaultProductSearchFields);
    } else {
      state = Set<String>.from(fields);
    }
  }
}
