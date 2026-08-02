/// Initial text for a list search field remounted after tab navigation.
///
/// Paginated list controllers are keepAlive and retain [currentSearchQuery]
/// across route disposal; local [TextEditingController]s do not.
String initialSearchFieldText(String? currentSearchQuery) =>
    currentSearchQuery ?? '';

/// Whether the search field clear button should be visible.
///
/// Shows clear when the local field has text, or when the keepAlive controller
/// still has an active search (so the user can clear after a remount).
bool shouldShowSearchClear({
  required String searchText,
  required bool isSearchActive,
}) =>
    searchText.isNotEmpty || isSearchActive;
