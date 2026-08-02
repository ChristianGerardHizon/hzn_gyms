/// Splits a user search string into non-empty whitespace-separated tokens.
///
/// Collapses runs of whitespace so `"chloe  sy"` and `"chloe sy"` both yield
/// `['chloe', 'sy']`. Returns an empty list when [query] is blank.
List<String> splitSearchTokens(String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const [];
  return trimmed.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
}

/// Whether [query] is long enough to run a member search.
///
/// Requires at least two characters, or one or more digits (phone prefix).
bool isMemberSearchQueryReady(String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.length >= 2) return true;
  return RegExp(r'^\d+$').hasMatch(trimmed);
}

/// Trims and collapses internal whitespace runs to a single space.
///
/// Useful for normalizing stored display names (e.g. `"CHLOE  SY"` → `"CHLOE SY"`).
String normalizeWhitespace(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Formats a person name for consistent storage/display.
///
/// - Collapses irregular whitespace
/// - Title-cases each word (`"CHLOE  SY"` → `"Chloe Sy"`)
/// - Capitalizes segments after `.` or `-` (`"MA.HOPE"` → `"Ma.Hope"`)
/// - Keeps common suffixes as `Jr` / `Sr` / `II` / `III` / `IV` / `V`
String formatPersonName(String value) {
  final normalized = normalizeWhitespace(value);
  if (normalized.isEmpty) return normalized;
  return normalized.split(' ').map(_formatPersonNameWord).join(' ');
}

String _formatPersonNameWord(String word) {
  final upper = word.toUpperCase();
  switch (upper) {
    case 'JR':
    case 'JR.':
      return upper.endsWith('.') ? 'Jr.' : 'Jr';
    case 'SR':
    case 'SR.':
      return upper.endsWith('.') ? 'Sr.' : 'Sr';
    case 'II':
    case 'III':
    case 'IV':
    case 'V':
      return upper;
  }

  return word.splitMapJoin(
    RegExp(r'[.\-]'),
    onMatch: (match) => match.group(0)!,
    onNonMatch: (part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    },
  );
}
