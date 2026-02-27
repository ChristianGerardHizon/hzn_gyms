import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_search_controller.g.dart';

/// Available search fields for members.
const memberSearchableFields = [
  'name',
  'mobileNumber',
  'email',
  'address',
  'rfidCardId',
];

/// Provider for managing which fields are included in member search.
@riverpod
class MemberSearchFields extends _$MemberSearchFields {
  @override
  Set<String> build() => {'name'}; // Default: only name

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
    state = {'name'};
  }

  void setFields(Set<String> fields) {
    if (fields.isEmpty) {
      state = {'name'};
    } else {
      state = fields;
    }
  }
}
