import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_search_controller.g.dart';

/// Available search fields for users.
const userSearchableFields = [
  'name',
  'username',
];

/// Provider for user search query state.
@riverpod
class UserSearchQuery extends _$UserSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for managing which fields are included in user search.
@riverpod
class UserSearchFields extends _$UserSearchFields {
  @override
  Set<String> build() => {'name', 'username'}; // Default: name and email

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
    state = {'name', 'username'};
  }

  void setFields(Set<String> fields) {
    // Ensure at least one field is selected
    if (fields.isEmpty) {
      state = {'name'}; // fallback to name
    } else {
      state = fields;
    }
  }
}
