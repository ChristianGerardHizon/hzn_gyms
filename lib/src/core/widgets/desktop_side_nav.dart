import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../i18n/strings.g.dart';
import 'app_brand_title.dart';
import '../navigation/app_nav_destination.dart';
import '../navigation/app_nav_presentation.dart';
import '../permissions/current_user_permissions.dart';
import '../routing/routes/platform.routes.dart';
import '../sync/outbox_sync_worker.dart';
import 'desktop_nav_flyout.dart';
import 'desktop_nav_item.dart';
import 'outbox_queue_badge.dart';

/// Firebase-style sidebar for tablet-large and desktop layouts (>=900px).
class DesktopSideNav extends HookConsumerWidget {
  const DesktopSideNav({
    super.key,
    required this.destinations,
    required this.onDestinationTap,
  });

  final List<AppNavDestination> destinations;
  final ValueChanged<AppNavDestination> onDestinationTap;

  static const double expandedWidth = 260;
  static const double collapsedWidth = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final collapsed = useState(false);
    final showAllShortcuts = useState(false);
    final searchQuery = useState('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    ref.watch(outboxPendingCountProvider);

    final location = GoRouterState.of(context).uri.path;
    final width = collapsed.value ? collapsedWidth : expandedWidth;
    final isSearching = !collapsed.value && searchQuery.value.trim().isNotEmpty;
    final searchResults = isSearching
        ? filterNavDestinationsByQuery(
            destinations,
            searchQuery.value,
            (id) => appNavLabel(id, t),
          )
        : const <AppNavDestination>[];

    final defaultShortcuts = visibleShortcutIds(destinations);
    final extraShortcuts = extraShortcutCandidates(destinations, defaultShortcuts);
    final shownShortcutIds = {
      ...defaultShortcuts,
      if (showAllShortcuts.value) ...extraShortcuts,
    };
    final excludedFromCategories = shownShortcutIds;

    final categories = visibleCategories(destinations, excludedFromCategories);

    AppNavDestination? destinationFor(AppNavId id) {
      for (final dest in destinations) {
        if (dest.id == id) return dest;
      }
      return null;
    }

    void clearSearch() {
      searchQuery.value = '';
      searchController.clear();
      searchFocusNode.unfocus();
    }

    void tapId(AppNavId id) {
      final dest = destinationFor(id);
      if (dest != null) onDestinationTap(dest);
    }

    void tapSearchResult(AppNavDestination dest) {
      onDestinationTap(dest);
      clearSearch();
    }

    Widget buildShortcutItem(AppNavId id) {
      final selected = isNavDestinationSelected(location, id, destinations);
      final icon = appNavIcon(id, selected: selected);
      final label = appNavLabel(id, t);

      if (id == AppNavId.outbox) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed.value ? 8 : 12,
            vertical: 2,
          ),
          child: OutboxQueueBadge(
            child: DesktopNavItem(
              icon: icon,
              label: label,
              selected: selected,
              collapsed: collapsed.value,
              onTap: () => tapId(id),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed.value ? 8 : 12,
          vertical: 2,
        ),
        child: DesktopNavItem(
          icon: icon,
          label: label,
          selected: selected,
          collapsed: collapsed.value,
          onTap: () => tapId(id),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed.value ? 12 : 20,
              20,
              collapsed.value ? 12 : 16,
              12,
            ),
            child: collapsed.value
                ? const Center(
                    child: AppBrandTitle(logoOnly: true, logoSize: 32),
                  )
                : const AppBrandTitle(),
          ),
          if (!collapsed.value)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _NavSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: t.navigation.searchNavHint,
                onChanged: (value) => searchQuery.value = value,
                onClear: clearSearch,
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: collapsed.value ? 8 : 12,
                        vertical: 2,
                      ),
                      child: DesktopNavItem(
                        icon: appNavIcon(
                          AppNavId.dashboard,
                          selected: isNavDestinationSelected(
                            location,
                            AppNavId.dashboard,
                            destinations,
                          ),
                        ),
                        label: t.navigation.dashboard,
                        selected: isNavDestinationSelected(
                          location,
                          AppNavId.dashboard,
                          destinations,
                        ),
                        collapsed: collapsed.value,
                        onTap: () => tapId(AppNavId.dashboard),
                      ),
                    ),
                    if (defaultShortcuts.isNotEmpty) ...[
                      if (!collapsed.value)
                        DesktopNavSectionHeader(label: t.navigation.shortcuts),
                      for (final id in defaultShortcuts) buildShortcutItem(id),
                      if (!collapsed.value && extraShortcuts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: TextButton.icon(
                            onPressed: () => showAllShortcuts.value =
                                !showAllShortcuts.value,
                            icon: Icon(
                              showAllShortcuts.value
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 18,
                            ),
                            label: Text(
                              showAllShortcuts.value
                                  ? t.navigation.showLess
                                  : t.navigation.showMore,
                            ),
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      if (showAllShortcuts.value)
                        for (final id in extraShortcuts) buildShortcutItem(id),
                    ],
                    if (categories.isNotEmpty) ...[
                      if (!collapsed.value)
                        DesktopNavSectionHeader(label: t.navigation.categories),
                      for (final category in categories)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: collapsed.value ? 8 : 12,
                            vertical: 4,
                          ),
                          child: DesktopNavCategoryRow(
                            category: category,
                            destinations: categoryDestinations(
                              category,
                              destinations,
                              excludedFromCategories,
                            ),
                            location: location,
                            collapsed: collapsed.value,
                            selected: isNavCategorySelected(
                              location,
                              category,
                              destinations,
                              excludedFromCategories,
                            ),
                            onDestinationTap: onDestinationTap,
                          ),
                        ),
                    ],
                    if (destinationFor(AppNavId.system) != null) ...[
                      SizedBox(height: collapsed.value ? 8 : 12),
                      if (!collapsed.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(height: 1),
                        ),
                      SizedBox(height: collapsed.value ? 4 : 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: collapsed.value ? 8 : 12,
                          vertical: 4,
                        ),
                        child: DesktopNavItem(
                          icon: appNavIcon(
                            AppNavId.system,
                            selected: isNavDestinationSelected(
                              location,
                              AppNavId.system,
                              destinations,
                            ),
                          ),
                          label: t.navigation.system,
                          selected: isNavDestinationSelected(
                            location,
                            AppNavId.system,
                            destinations,
                          ),
                          collapsed: collapsed.value,
                          onTap: () => tapId(AppNavId.system),
                          trailing: collapsed.value
                              ? null
                              : Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isSearching)
                  Positioned.fill(
                    child: _NavSearchResultsOverlay(
                      results: searchResults,
                      location: location,
                      destinations: destinations,
                      resultsLabel: t.navigation.searchResults,
                      emptyLabel: t.navigation.noSearchResults,
                      labelFor: (id) => appNavLabel(id, t),
                      onResultTap: tapSearchResult,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed.value ? 4 : 8,
              12,
              collapsed.value ? 4 : 8,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ref
                        .watch(currentUserPermissionsProvider)
                        .value
                        ?.canManageOrganizations ??
                    false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DesktopNavItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: t.organizations.platformTitle,
                      selected: false,
                      collapsed: collapsed.value,
                      onTap: () => const PlatformDashboardRoute().go(context),
                    ),
                  ),
                DesktopNavItem(
                  icon: Icons.logout,
                  label: t.auth.logoutButton,
                  selected: false,
                  collapsed: collapsed.value,
                  onTap: () => _confirmLogout(context, ref, t),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: collapsed.value
                        ? t.navigation.expandNav
                        : t.navigation.collapseNav,
                    icon: Icon(
                      collapsed.value
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                    ),
                    onPressed: () {
                      final next = !collapsed.value;
                      if (next) clearSearch();
                      collapsed.value = next;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, Translations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.auth.logoutButton),
        content: Text(t.auth.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(t.auth.logoutButton),
          ),
        ],
      ),
    );
  }
}

class _NavSearchField extends StatelessWidget {
  const _NavSearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasText = controller.text.isNotEmpty;

    return Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: Icon(
                    Icons.cancel,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _NavSearchResultsOverlay extends StatelessWidget {
  const _NavSearchResultsOverlay({
    required this.results,
    required this.location,
    required this.destinations,
    required this.resultsLabel,
    required this.emptyLabel,
    required this.labelFor,
    required this.onResultTap,
  });

  final List<AppNavDestination> results;
  final String location;
  final List<AppNavDestination> destinations;
  final String resultsLabel;
  final String emptyLabel;
  final String Function(AppNavId id) labelFor;
  final ValueChanged<AppNavDestination> onResultTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 4,
      color: colorScheme.surfaceContainerHigh,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              resultsLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                emptyLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final dest in results)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: DesktopNavItem(
                  icon: appNavIcon(
                    dest.id,
                    selected: isNavDestinationSelected(
                      location,
                      dest.id,
                      destinations,
                    ),
                  ),
                  label: labelFor(dest.id),
                  selected: isNavDestinationSelected(
                    location,
                    dest.id,
                    destinations,
                  ),
                  onTap: () => onResultTap(dest),
                ),
              ),
        ],
      ),
    );
  }
}
