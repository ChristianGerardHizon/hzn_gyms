import '../../utils/date_utils.dart';

/// Builder class for constructing PocketBase filter strings.
///
/// Provides a fluent API for building type-safe filter queries.
///
/// Example:
/// ```dart
/// final filter = PBFilter()
///   .equals('species', 'dog')
///   .notDeleted()
///   .build();
/// // Result: "species = 'dog' && isDeleted = false"
/// ```
class PBFilter {
  final List<String> _conditions;

  /// Creates a new filter builder.
  ///
  /// Optionally accepts initial conditions to start with.
  PBFilter([List<String>? initial]) : _conditions = List.from(initial ?? []);

  // --- Equality Operators ---

  /// Exact equality: field = 'value'
  PBFilter equals(String field, String value) {
    _conditions.add("$field = '${escape(value)}'");
    return this;
  }

  /// Not equal: field != 'value'
  PBFilter notEquals(String field, String value) {
    _conditions.add("$field != '${escape(value)}'");
    return this;
  }

  /// Relation ID match: field = "id"
  ///
  /// Used for foreign key fields where PocketBase expects double quotes.
  PBFilter relation(String field, String id) {
    _conditions.add('$field = "$id"');
    return this;
  }

  // --- Comparison Operators ---

  /// Greater than: field > value
  PBFilter greaterThan(String field, dynamic value) {
    _conditions.add('$field > ${_formatValue(value)}');
    return this;
  }

  /// Less than: field < value
  PBFilter lessThan(String field, dynamic value) {
    _conditions.add('$field < ${_formatValue(value)}');
    return this;
  }

  /// Greater or equal: field >= value
  PBFilter greaterOrEqual(String field, dynamic value) {
    _conditions.add('$field >= ${_formatValue(value)}');
    return this;
  }

  /// Less or equal: field <= value
  PBFilter lessOrEqual(String field, dynamic value) {
    _conditions.add('$field <= ${_formatValue(value)}');
    return this;
  }

  // --- String Search ---

  /// Wildcard search: field ~ 'value'
  ///
  /// Matches records where field contains the value.
  PBFilter contains(String field, String value) {
    _conditions.add("$field ~ '${escape(value)}'");
    return this;
  }

  /// Search multiple fields with OR: (field1 ~ 'q' || field2 ~ 'q')
  ///
  /// Useful for implementing search across multiple columns.
  PBFilter searchFields(String query, List<String> fields) {
    if (query.isEmpty || fields.isEmpty) return this;

    final escaped = escape(query);
    final orConditions = fields.map((f) => "$f ~ '$escaped'").join(' || ');
    _conditions.add('($orConditions)');
    return this;
  }

  // --- Boolean ---

  /// Boolean true: field = true
  PBFilter isTrue(String field) {
    _conditions.add('$field = true');
    return this;
  }

  /// Boolean false: field = false
  PBFilter isFalse(String field) {
    _conditions.add('$field = false');
    return this;
  }

  // --- Date/Time ---

  /// Date after: field >= 'PocketBase UTC format'
  PBFilter after(String field, DateTime date) {
    final utcStr = date.toPocketBaseUtc();
    _conditions.add("$field >= '$utcStr'");
    return this;
  }

  /// Date before: field <= 'PocketBase UTC format'
  PBFilter before(String field, DateTime date) {
    final utcStr = date.toPocketBaseUtc();
    _conditions.add("$field <= '$utcStr'");
    return this;
  }

  /// Date range: field >= 'start' && field <= 'end'
  PBFilter between(String field, DateTime start, DateTime end) {
    final startUtc = start.toPocketBaseUtc();
    final endUtc = end.toPocketBaseUtc();
    _conditions.add("($field >= '$startUtc' && $field <= '$endUtc')");
    return this;
  }

  // --- Null Checks ---

  /// Is null or empty: field = '' || field = null
  PBFilter isNull(String field) {
    _conditions.add("($field = '' || $field = null)");
    return this;
  }

  /// Is not null and not empty: field != '' && field != null
  PBFilter isNotNull(String field) {
    _conditions.add("($field != '' && $field != null)");
    return this;
  }

  // --- Logical Grouping ---

  /// Combine with another filter using AND.
  ///
  /// All conditions from the other filter are added to this one.
  PBFilter and(PBFilter other) {
    _conditions.addAll(other._conditions);
    return this;
  }

  /// Combine with another filter using OR.
  ///
  /// The other filter's conditions are wrapped in parentheses.
  PBFilter or(PBFilter other) {
    if (other._conditions.isEmpty) return this;

    final otherConditions = other._conditions.join(' && ');
    if (_conditions.isEmpty) {
      _conditions.add(otherConditions);
    } else {
      final currentConditions = _conditions.join(' && ');
      _conditions.clear();
      _conditions.add('($currentConditions) || ($otherConditions)');
    }
    return this;
  }

  // --- Common Presets ---

  /// Adds: isDeleted = false
  ///
  /// Standard soft delete filter.
  PBFilter notDeleted() {
    _conditions.add('isDeleted = false');
    return this;
  }

  /// Adds: isActive = true
  PBFilter isActive() {
    _conditions.add('isActive = true');
    return this;
  }

  // --- Build ---

  /// Returns the filter string or null if no conditions.
  String? build() {
    if (_conditions.isEmpty) return null;
    return _conditions.join(' && ');
  }

  /// Returns the filter string or empty string if no conditions.
  String buildOrEmpty() {
    return build() ?? '';
  }

  /// Returns true if no conditions have been added.
  bool get isEmpty => _conditions.isEmpty;

  /// Returns the number of conditions.
  int get length => _conditions.length;

  // --- Static Helpers ---

  /// Escapes special characters in string values.
  ///
  /// Handles single quotes which are used as string delimiters in PocketBase.
  static String escape(String value) {
    return value.replaceAll("'", "\\'").replaceAll('"', '\\"');
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return "'${escape(value)}'";
    } else if (value is DateTime) {
      return "'${value.toPocketBaseUtc()}'";
    } else {
      return value.toString();
    }
  }

  @override
  String toString() => build() ?? '';
}

/// Pre-defined filter configurations for common queries.
///
/// Provides factory methods for standard filter patterns used throughout
/// the application.
abstract class PBFilters {
  /// Base filter excluding soft-deleted records.
  static PBFilter get active => PBFilter().notDeleted();

  /// Filter for member-related queries with soft delete.
  ///
  /// Example: `PBFilters.forMember(memberId).build()`
  /// Result: `member = "id" && isDeleted = false`
  static PBFilter forMember(String memberId) =>
      PBFilter().relation('member', memberId).notDeleted();

  /// Filter for branch-scoped queries with soft delete.
  ///
  /// Example: `PBFilters.forBranch(branchId).build()`
  /// Result: `branch = "id" && isDeleted = false`
  static PBFilter forBranch(String branchId) =>
      PBFilter().relation('branch', branchId).notDeleted();
}
