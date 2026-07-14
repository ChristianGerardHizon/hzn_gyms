/// Layout preference for the dashboard members grid.
///
/// Preferred [columns] is persisted; the effective count is clamped to what
/// fits the current screen width via [resolveColumns].
class DashboardMembersLayout {
  const DashboardMembersLayout({
    this.columns = defaultColumns,
    this.showPhoto = true,
  });

  /// Default preferred column count when no preference is stored.
  static const int defaultColumns = 4;

  /// All persistable column counts (actual options depend on screen width).
  static const List<int> allowedColumns = [1, 2, 3, 4, 5];

  /// Matches [Breakpoints.mobile] — below this: 1–2 columns.
  static const double mobileBreakpoint = 600;

  /// Matches [Breakpoints.tablet] — below this (and ≥ mobile): 2–3 columns.
  static const double tabletBreakpoint = 900;

  /// Matches [Breakpoints.desktop] — at/above this: 2–5 columns.
  static const double desktopBreakpoint = 1200;

  /// Preferred number of columns (1–5); may be capped by screen size.
  final int columns;

  /// When true, cards show the member photo; when false, name + expiry only.
  final bool showPhoto;

  /// Grid child aspect ratio for the current display mode.
  double get childAspectRatio => childAspectRatioFor(showPhoto: showPhoto);

  /// Aspect ratio for photo vs name-only tiles.
  static double childAspectRatioFor({required bool showPhoto}) =>
      showPhoto ? 0.75 : 2.8;

  /// Column options offered for the given layout width.
  ///
  /// - Mobile (&lt; 600): 1–2
  /// - Tablet medium (600–899): 2–3
  /// - Tablet large (900–1199): 2–4
  /// - Desktop (≥ 1200): 2–5
  static List<int> allowedColumnsForWidth(double width) {
    if (width < mobileBreakpoint) return const [1, 2];
    if (width < tabletBreakpoint) return const [2, 3];
    if (width < desktopBreakpoint) return const [2, 3, 4];
    return const [2, 3, 4, 5];
  }

  /// Resolves [preferred] to a column count that fits [width].
  ///
  /// Does not change the stored preference — only the displayed grid.
  static int resolveColumns({
    required int preferred,
    required double width,
  }) {
    final allowed = allowedColumnsForWidth(width);
    if (allowed.contains(preferred)) return preferred;
    final max = allowed.last;
    if (preferred > max) return max;
    return allowed.first;
  }

  /// Effective columns for [width] given this preference.
  int effectiveColumnsForWidth(double width) =>
      resolveColumns(preferred: columns, width: width);

  /// Clamps [value] to [allowedColumns], falling back to [defaultColumns].
  static int clampColumns(int value) {
    if (allowedColumns.contains(value)) return value;
    return defaultColumns;
  }

  DashboardMembersLayout copyWith({
    int? columns,
    bool? showPhoto,
  }) {
    return DashboardMembersLayout(
      columns: columns != null ? clampColumns(columns) : this.columns,
      showPhoto: showPhoto ?? this.showPhoto,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardMembersLayout &&
          columns == other.columns &&
          showPhoto == other.showPhoto;

  @override
  int get hashCode => Object.hash(columns, showPhoto);
}
