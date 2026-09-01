import '../../utils/date_utils.dart';
import '../../utils/search_tokens.dart';

/// Builder class for constructing PocketBase filter strings.
///
/// Provides a fluent API for building type-safe filter queries.
///
/// Example:
/// ```dart
/// final filter = PBFilter()
///   .equals('name', 'John')
///   .notDeleted()
///   .build();
/// // Result: "name = 'John' && isDeleted = false"
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

  /// Relation ID match for any of [ids]: (field = "a" || field = "b" || ...)
  ///
  /// No-op when [ids] is empty.
  PBFilter relationAny(String field, Iterable<String> ids) {
    final uniqueIds = ids.toSet();
    if (uniqueIds.isEmpty) return this;

    final orConditions = uniqueIds
        .map((id) => '$field = "${escape(id)}"')
        .join(' || ');
    _conditions.add('($orConditions)');
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

  /// Search multiple fields, tokenized on whitespace.
  ///
  /// Each whitespace-separated token must match at least one field:
  /// `(f1 ~ 'a' || f2 ~ 'a') && (f1 ~ 'b' || f2 ~ 'b')`
  ///
  /// This tolerates irregular spacing in stored values (e.g. `"CHLOE  SY"`
  /// still matches query `"chloe sy"`) and allows out-of-order name parts.
  PBFilter searchFields(String query, List<String> fields) {
    if (query.isEmpty || fields.isEmpty) return this;

    final tokens = splitSearchTokens(query);
    if (tokens.isEmpty) return this;

    for (final token in tokens) {
      final escaped = escape(token);
      final orConditions = fields.map((f) => "$f ~ '$escaped'").join(' || ');
      _conditions.add('($orConditions)');
    }
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

  /// Adds a raw filter expression (already parenthesized if needed).
  PBFilter raw(String expression) {
    if (expression.isNotEmpty) {
      _conditions.add(expression);
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

  /// Filter for organization-scoped queries with soft delete.
  ///
  /// Example: `PBFilters.forOrganization(organizationId).build()`
  /// Result: `organization = "id" && isDeleted = false`
  static PBFilter forOrganization(String organizationId) =>
      PBFilter().relation('organization', organizationId).notDeleted();

  /// Currently active member subscriptions.
  ///
  /// `startDate <= now` and `endDate >= start of today` (local). The end
  /// date is date-only and inclusive through that calendar day, so a
  /// membership ending today stays valid until midnight.
  static PBFilter activeMemberMemberships({DateTime? now}) {
    final current = now ?? DateTime.now();
    return PBFilter()
        .equals('status', 'active')
        .lessOrEqual('startDate', current)
        .greaterOrEqual('endDate', toLocalDateOnly(current));
  }
}
