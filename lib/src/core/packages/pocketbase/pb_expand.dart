/// Helper class for building PocketBase expand strings.
///
/// Expand strings are used to fetch related records in a single query.
class Expand {
  final List<String> paths;

  const Expand._(this.paths);

  /// Creates an expand with flat paths (no nesting).
  ///
  /// Example:
  /// ```dart
  /// Expand.flat(['branch', 'category'])
  /// // Result: "branch, category"
  /// ```
  factory Expand.flat(List<String> paths) => Expand._(paths);

  /// Creates an expand with nested paths from a root.
  ///
  /// Example:
  /// ```dart
  /// Expand.nested('member', ['branch'])
  /// // Result: "member, member.branch"
  /// ```
  factory Expand.nested(String root, List<String> subPaths) {
    return Expand._([
      root,
      for (var sub in subPaths) '$root.$sub',
    ]);
  }

  /// Combines multiple expands into one.
  factory Expand.combine(List<Expand> expands) {
    return Expand._(expands.expand((e) => e.paths).toList());
  }

  @override
  String toString() => paths.join(', ');
}

/// Pre-defined expand configurations for common queries.
abstract class PBExpand {
  /// Expand for user queries - includes branch relation.
  static final Expand user = Expand.flat(['branch']);

  /// Expand for member queries - includes branch relation.
  static final Expand member = Expand.flat(['branch']);

  /// Expand for product queries - includes category and branch.
  static final Expand product = Expand.flat(['category', 'branch']);

  /// Expand for sale queries - includes items and branch.
  static final Expand sale = Expand.flat(['items', 'branch']);
}
