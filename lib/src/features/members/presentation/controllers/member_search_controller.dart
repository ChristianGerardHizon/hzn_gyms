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

/// Default fields selected for member search.
const defaultMemberSearchFields = {'name'};

/// Provider for managing which fields are included in member search.
@riverpod
class MemberSearchFields extends _$MemberSearchFields {
  @override
  Set<String> build() => Set<String>.from(defaultMemberSearchFields);

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
    state = Set<String>.from(defaultMemberSearchFields);
  }

  void setFields(Set<String> fields) {
    if (fields.isEmpty) {
      state = Set<String>.from(defaultMemberSearchFields);
    } else {
      state = Set<String>.from(fields);
    }
  }
}
