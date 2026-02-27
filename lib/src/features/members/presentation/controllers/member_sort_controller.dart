import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/sort_config.dart';

part 'member_sort_controller.g.dart';

/// Default sort configuration for members (by name ascending).
const memberDefaultSort = SortConfig(field: 'name', descending: false);

/// Available sortable fields for members.
const memberSortableFields = <SortableField>[
  (key: 'name', label: 'Name'),
  (key: 'mobileNumber', label: 'Mobile Number'),
  (key: 'email', label: 'Email'),
  (key: 'created', label: 'Date Added'),
  (key: 'updated', label: 'Last Updated'),
];

/// Provider for managing member list sort configuration.
@riverpod
class MemberSortController extends _$MemberSortController {
  @override
  SortConfig build() => memberDefaultSort;

  /// Sets the sort configuration.
  void setSort(SortConfig config) => state = config;

  /// Sets only the sort field, keeping the current direction.
  void setSortField(String field) {
    state = state.copyWith(field: field);
  }

  /// Toggles the sort direction.
  void toggleDirection() {
    state = state.toggleDirection();
  }

  /// Resets to default sort.
  void reset() => state = memberDefaultSort;
}
