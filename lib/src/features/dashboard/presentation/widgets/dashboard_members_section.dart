import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/utils/perf_logger.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/state/empty_state.dart';
import '../../../memberships/domain/days_remaining_label.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/dashboard_members_layout.dart';
import '../controllers/dashboard_members_controller.dart';
import '../controllers/dashboard_members_layout_controller.dart';
import '../controllers/dashboard_members_page_errors.dart';
import 'member_quick_view_dialog.dart';

/// Section displaying members as a virtualized grid of photo cards.
///
/// Returns a [SliverMainAxisGroup] containing header, search bar, filter
/// chips, member grid, and load-more sentinel. Must be placed inside a
/// [CustomScrollView].
class DashboardMembersSection extends HookConsumerWidget {
  const DashboardMembersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawSearchInput = useState('');
    final debouncedQuery = useState('');
    final allMembers = useState(<DashboardMember>[]);
    final totalItems = useState(0);
    final totalPages = useState(0);
    final loadedUpToPage = useState(0);
    final hasMore = useState(true);
    final isLoadingMore = useState(false);
    final hasLoadedOnce = useState(false);
    final statusFilter = useState(MemberStatusFilter.all);
    final loadPerf = useRef<PerfTimer?>(null);
    final prefetchInFlight = useRef(<int>{});
    final prefetchGeneration = useRef(0);
    final sectionMounted = useRef(true);
    final layout = ref.watch(currentDashboardMembersLayoutProvider);

    // Branch scope — local list state must reset when this changes, otherwise
    // page-1 updates are ignored once [loadedUpToPage] > 0.
    final branchId = ref.watch(currentBranchIdProvider);
    final viewingAll = ref.watch(viewingAllBranchesProvider);
    final branchScopeKey = viewingAll ? 'all' : (branchId ?? 'none');

    useEffect(() {
      sectionMounted.value = true;
      return () {
        sectionMounted.value = false;
        prefetchGeneration.value++;
      };
    }, const []);

    // Debounce search input by 400ms
    useEffect(() {
      if (rawSearchInput.value.isEmpty) {
        debouncedQuery.value = '';
        return null;
      }
      final timer = Timer(const Duration(milliseconds: 400), () {
        debouncedQuery.value = rawSearchInput.value;
      });
      return timer.cancel;
    }, [rawSearchInput.value]);

    // Reset pagination when branch, search, or status filter changes.
    useEffect(() {
      allMembers.value = [];
      totalItems.value = 0;
      loadedUpToPage.value = 0;
      totalPages.value = 0;
      hasMore.value = true;
      isLoadingMore.value = false;
      hasLoadedOnce.value = false;
      prefetchInFlight.value = <int>{};
      prefetchGeneration.value++;
      loadPerf.value?.finish('CANCELLED (branch/filter/search changed)');
      loadPerf.value = null;
      return null;
    }, [branchScopeKey, debouncedQuery.value, statusFilter.value]);

    // Always watch page 1; later pages are prefetched into local state.
    final query = debouncedQuery.value.isEmpty ? null : debouncedQuery.value;
    final pageAsync = ref.watch(
      dashboardMembersPageProvider(
        page: 1,
        searchQuery: query,
        statusFilter: statusFilter.value,
      ),
    );

    Future<void> prefetchAhead(int basePage) async {
      final generation = prefetchGeneration.value;
      final pagesToFetch = <int>[
        for (var p = basePage + 1; p <= basePage + 2; p++)
          if (p <= totalPages.value &&
              p > loadedUpToPage.value &&
              !prefetchInFlight.value.contains(p))
            p,
      ];
      if (pagesToFetch.isEmpty) return;

      bool canCommit() => canCommitDashboardMembersPrefetch(
            requestGeneration: generation,
            currentGeneration: prefetchGeneration.value,
            isMounted: sectionMounted.value && context.mounted,
          );

      if (!canCommit()) return;

      prefetchInFlight.value = {
        ...prefetchInFlight.value,
        ...pagesToFetch,
      };

      try {
        final results = await Future.wait(
          pagesToFetch.map((pageNum) async {
            final provider = dashboardMembersPageProvider(
              page: pageNum,
              searchQuery: query,
              statusFilter: statusFilter.value,
            );
            // Keep a listener while awaiting so autoDispose cannot tear down
            // the provider mid-load (prefetch only uses `.future`).
            final sub = ref.listenManual(
              provider,
              (_, __) {},
              fireImmediately: true,
            );
            try {
              return await ref.read(provider.future);
            } finally {
              sub.close();
            }
          }),
        );

        if (!canCommit()) return;

        results.sort((a, b) => a.page.compareTo(b.page));

        var members = allMembers.value;
        final existingIds = members.map((m) => m.id).toSet();
        for (final page in results) {
          final newItems =
              page.items.where((m) => !existingIds.contains(m.id)).toList();
          if (newItems.isNotEmpty) {
            members = [...members, ...newItems];
            existingIds.addAll(newItems.map((m) => m.id));
          }
          totalItems.value = page.totalItems;
          totalPages.value = page.totalPages;
        }
        allMembers.value = members;

        final highestFetched = results.last.page;
        if (highestFetched > loadedUpToPage.value) {
          loadedUpToPage.value = highestFetched;
        }
        hasMore.value = loadedUpToPage.value < totalPages.value;
      } on Object catch (error) {
        if (isProviderDisposedDuringLoading(error) ||
            isUsedAfterDisposeError(error) ||
            !canCommit()) {
          return;
        }
        rethrow;
      } finally {
        // Always clear in-flight pages so a superseded/cancelled prefetch
        // does not leave the load-more spinner stuck or skip later pages.
        try {
          final next = {...prefetchInFlight.value}..removeAll(pagesToFetch);
          prefetchInFlight.value = next;
          if (prefetchInFlight.value.isEmpty) {
            isLoadingMore.value = false;
          }
        } on Object catch (error) {
          if (!isUsedAfterDisposeError(error)) rethrow;
        }
      }
    }

    // Track provider lifecycle for performance debugging.
    useEffect(() {
      if (pageAsync.isLoading) {
        loadPerf.value ??= PerfTimer(
          'dashboardMembersSection p1 '
          '${statusFilter.value.name}'
          '${query != null ? ' q="$query"' : ''}',
        );
        loadPerf.value!.checkpoint('provider loading');
      } else if (pageAsync.hasError) {
        loadPerf.value?.checkpoint('provider error: ${pageAsync.error}');
        loadPerf.value?.finish('FAILED');
        loadPerf.value = null;
      }
      return null;
    }, [pageAsync.isLoading, pageAsync.hasError, pageAsync.error]);

    // When page 1 arrives after a reset, replace the list and silently
    // prefetch pages 2–3 so two pages stay buffered ahead.
    useEffect(() {
      // Skip while refreshing — previous AsyncData would re-seed the list
      // with the old branch's members right after a branch-scope reset.
      if (pageAsync.isLoading) return null;

      pageAsync.whenData((page) {
        // Ignore re-emissions once this query has been initialized; otherwise
        // page-1 data would wipe already-prefetched pages from the list.
        if (loadedUpToPage.value > 0) return;
        if (!sectionMounted.value || !context.mounted) return;

        loadPerf.value?.checkpoint(
          'provider data received (${page.items.length} items)',
        );

        allMembers.value = page.items;
        totalItems.value = page.totalItems;
        totalPages.value = page.totalPages;
        loadedUpToPage.value = 1;
        hasMore.value = page.hasMore;
        isLoadingMore.value = false;
        hasLoadedOnce.value = true;

        loadPerf.value?.checkpoint(
          'UI state updated (${allMembers.value.length} members shown)',
        );
        loadPerf.value?.finish();
        loadPerf.value = null;

        if (page.hasMore) {
          unawaited(prefetchAhead(1));
        }
      });
      return null;
    }, [pageAsync, branchScopeKey]);

    // Full loading state after branch/search/filter reset (or first visit).
    // Until page 1 has been applied for the current scope, never show the
    // previous scope's cards (list was cleared) or a false empty state.
    final isInitialLoad = !hasLoadedOnce.value && !pageAsync.hasError;

    // Show loading indicator in the grid area while searching/filtering
    final isSearchLoading =
        pageAsync.isLoading && hasLoadedOnce.value;

    return SliverMainAxisGroup(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Members',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${totalItems.value}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.sizeOf(context).width;
                        final columnOptions =
                            DashboardMembersLayout.allowedColumnsForWidth(
                          screenWidth,
                        );
                        final effectiveColumns =
                            layout.effectiveColumnsForWidth(screenWidth);

                        return PopupMenuButton<_LayoutMenuAction>(
                          tooltip: 'Layout options',
                          icon:
                              const Icon(Icons.view_quilt_outlined, size: 20),
                          onSelected: (action) {
                            final controller = ref.read(
                              dashboardMembersLayoutControllerProvider
                                  .notifier,
                            );
                            switch (action) {
                              case _LayoutMenuAction.columns1:
                                unawaited(controller.setColumns(1));
                              case _LayoutMenuAction.columns2:
                                unawaited(controller.setColumns(2));
                              case _LayoutMenuAction.columns3:
                                unawaited(controller.setColumns(3));
                              case _LayoutMenuAction.columns4:
                                unawaited(controller.setColumns(4));
                              case _LayoutMenuAction.columns5:
                                unawaited(controller.setColumns(5));
                              case _LayoutMenuAction.photo:
                                unawaited(controller.setShowPhoto(true));
                              case _LayoutMenuAction.nameOnly:
                                unawaited(controller.setShowPhoto(false));
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              enabled: false,
                              child: Text('Columns'),
                            ),
                            ...columnOptions.map(
                              (count) =>
                                  CheckedPopupMenuItem<_LayoutMenuAction>(
                                value: _layoutMenuActionForColumns(count),
                                checked: effectiveColumns == count,
                                child: Text('$count'),
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              enabled: false,
                              child: Text('Display'),
                            ),
                            CheckedPopupMenuItem<_LayoutMenuAction>(
                              value: _LayoutMenuAction.photo,
                              checked: layout.showPhoto,
                              child: const Text('Photo'),
                            ),
                            CheckedPopupMenuItem<_LayoutMenuAction>(
                              value: _LayoutMenuAction.nameOnly,
                              checked: !layout.showPhoto,
                              child: const Text('Name only'),
                            ),
                          ],
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () => const MembersRoute().goScoped(context),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search member...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    rawSearchInput.value = value;
                  },
                ),
                const SizedBox(height: 8),
                // Filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MemberStatusFilter.values.map((filter) {
                    final isSelected = filter == statusFilter.value;
                    return ChoiceChip(
                      label: Text(filter.label),
                      selected: isSelected,
                      onSelected: (_) {
                        statusFilter.value = filter;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // Initial loading spinner
        if (isInitialLoad)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        // Error on first load
        else if (pageAsync.hasError && !hasLoadedOnce.value)
          const SliverToBoxAdapter(child: SizedBox.shrink())
        // Empty state
        else if (allMembers.value.isEmpty && !pageAsync.isLoading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _DashboardMembersEmptyState(
                hasSearch: debouncedQuery.value.isNotEmpty,
                statusFilter: statusFilter.value,
              ),
            ),
          )
        // Member grid (virtualized via SliverGrid)
        else ...[
          if (isSearchLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final crossAxisCount =
                    layout.effectiveColumnsForWidth(screenWidth);
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: layout.childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // When near the end of the buffered list, prefetch the
                      // next 2 pages so at least 2 pages stay ahead.
                      if (index >= allMembers.value.length - 4 &&
                          hasMore.value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!sectionMounted.value || !context.mounted) {
                            return;
                          }
                          if (!hasMore.value) return;
                          // Show a spinner if the user has caught up to
                          // in-flight background fetches.
                          if (prefetchInFlight.value.isNotEmpty) {
                            isLoadingMore.value = true;
                            return;
                          }
                          isLoadingMore.value = true;
                          unawaited(prefetchAhead(loadedUpToPage.value));
                        });
                      }
                      return _DashboardMemberCard(
                        dashboardMember: allMembers.value[index],
                        showPhoto: layout.showPhoto,
                      );
                    },
                    childCount: allMembers.value.length,
                  ),
                );
              },
            ),
          ),
        ],
        // Loading indicator only when the user is waiting on more pages
        // (silent background prefetch does not show this).
        if (hasMore.value &&
            isLoadingMore.value &&
            prefetchInFlight.value.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state for the dashboard members grid.
class _DashboardMembersEmptyState extends StatelessWidget {
  const _DashboardMembersEmptyState({
    required this.hasSearch,
    required this.statusFilter,
  });

  final bool hasSearch;
  final MemberStatusFilter statusFilter;

  @override
  Widget build(BuildContext context) {
    final (:icon, :title, :subtitle) = switch ((hasSearch, statusFilter)) {
      (true, _) => (
          icon: Icons.search_off_rounded,
          title: 'No members found',
          subtitle: 'Try a different name or clear your search',
        ),
      (false, MemberStatusFilter.active) => (
          icon: Icons.person_off_outlined,
          title: 'No active members',
          subtitle: 'No members currently have an active membership',
        ),
      (false, MemberStatusFilter.expiringSoon) => (
          icon: Icons.event_busy_outlined,
          title: 'None expiring soon',
          subtitle: 'No memberships expire within the next 7 days',
        ),
      (false, MemberStatusFilter.expired) => (
          icon: Icons.hourglass_disabled_outlined,
          title: 'No expired members',
          subtitle: 'There are no members with expired memberships',
        ),
      (false, MemberStatusFilter.all) => (
          icon: Icons.people_outline,
          title: 'No members yet',
          subtitle: 'Registered members will appear here',
        ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconSize: 56,
    );
  }
}

/// Actions for the members layout popup menu.
enum _LayoutMenuAction {
  columns1,
  columns2,
  columns3,
  columns4,
  columns5,
  photo,
  nameOnly,
}

_LayoutMenuAction _layoutMenuActionForColumns(int count) => switch (count) {
      1 => _LayoutMenuAction.columns1,
      2 => _LayoutMenuAction.columns2,
      3 => _LayoutMenuAction.columns3,
      4 => _LayoutMenuAction.columns4,
      _ => _LayoutMenuAction.columns5,
    };

/// A card showing a member's photo (optional) with expiration info and name.
class _DashboardMemberCard extends StatelessWidget {
  const _DashboardMemberCard({
    required this.dashboardMember,
    required this.showPhoto,
  });

  final DashboardMember dashboardMember;
  final bool showPhoto;

  String? _thumbnailUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    final separator = photoUrl.contains('?') ? '&' : '?';
    return '$photoUrl${separator}thumb=200x200';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = dashboardMember.daysUntilExpiry;
    final isExpired = dashboardMember.isExpired;
    final showBadge = days != null && (isExpired || days <= 7);

    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpired
            ? BorderSide(color: theme.colorScheme.error, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => showMemberQuickViewDialog(
          context,
          memberId: dashboardMember.id,
          dashboardMember: dashboardMember,
        ),
        child: showPhoto
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedImage(
                          imageUrl: _thumbnailUrl(dashboardMember.photo),
                        ),
                        if (showBadge)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: _DaysLeftBadge(days: days),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: _MemberCardLabels(
                      name: dashboardMember.name,
                      expirationDate: dashboardMember.expirationDate,
                      isExpired: isExpired,
                    ),
                  ),
                ],
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showBadge) ...[
                      _DaysLeftBadge(days: days),
                      const SizedBox(height: 4),
                    ],
                    _MemberCardLabels(
                      name: dashboardMember.name,
                      expirationDate: dashboardMember.expirationDate,
                      isExpired: isExpired,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Name + expiration labels shared by photo and name-only cards.
class _MemberCardLabels extends StatelessWidget {
  const _MemberCardLabels({
    required this.name,
    required this.expirationDate,
    required this.isExpired,
  });

  final String name;
  final DateTime? expirationDate;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          expirationDate != null
              ? DateFormat('MMM d, y').format(expirationDate!)
              : 'No membership',
          style: theme.textTheme.labelSmall?.copyWith(
            color: isExpired
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A compact badge showing how many days are left until expiration.
class _DaysLeftBadge extends StatelessWidget {
  const _DaysLeftBadge({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    final days = this.days;
    final String label;
    final Color backgroundColor;

    if (days == null) {
      label = 'No membership';
      backgroundColor = Colors.grey.shade700;
    } else if (days < 0) {
      label = 'Expired';
      backgroundColor = Colors.red.shade700;
    } else {
      label = formatDaysRemainingLabel(days);
      backgroundColor = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
      ),
    );
  }
}
