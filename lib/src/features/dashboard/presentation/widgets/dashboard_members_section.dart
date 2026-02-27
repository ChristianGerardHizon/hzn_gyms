import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../controllers/dashboard_members_controller.dart';

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
    final currentPage = useState(1);
    final allMembers = useState(<DashboardMember>[]);
    final totalItems = useState(0);
    final hasMore = useState(true);
    final isLoadingMore = useState(false);
    final hasLoadedOnce = useState(false);
    final statusFilter = useState(MemberStatusFilter.all);

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

    // Reset pagination when debounced query or filter changes
    useEffect(() {
      currentPage.value = 1;
      hasMore.value = true;
      return null;
    }, [debouncedQuery.value, statusFilter.value]);

    // Fetch the current page (now with server-side filtering)
    final query = debouncedQuery.value.isEmpty ? null : debouncedQuery.value;
    final pageAsync = ref.watch(
      dashboardMembersPageProvider(
        page: currentPage.value,
        searchQuery: query,
        statusFilter: statusFilter.value,
      ),
    );

    // When new page data arrives, append it to the list
    useEffect(() {
      pageAsync.whenData((page) {
        if (currentPage.value == 1) {
          allMembers.value = page.items;
        } else {
          final existingIds = allMembers.value.map((m) => m.id).toSet();
          final newItems =
              page.items.where((m) => !existingIds.contains(m.id));
          allMembers.value = [...allMembers.value, ...newItems];
        }
        totalItems.value = page.totalItems;
        hasMore.value = page.hasMore;
        isLoadingMore.value = false;
        hasLoadedOnce.value = true;
      });
      return null;
    }, [pageAsync]);

    // Initial loading state (never loaded any data yet)
    final isInitialLoad = !hasLoadedOnce.value && pageAsync.isLoading;

    // Show loading indicator in the grid area while searching/filtering
    final isSearchLoading =
        pageAsync.isLoading && currentPage.value == 1 && hasLoadedOnce.value;

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
                    TextButton(
                      onPressed: () => const MembersRoute().go(context),
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  statusFilter.value != MemberStatusFilter.all
                      ? 'No ${statusFilter.value.label.toLowerCase()} members found'
                      : 'No members found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
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
                final crossAxisCount =
                    constraints.crossAxisExtent > 600 ? 4 : 3;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Auto-fetch next page when building items near the end
                      if (index >= allMembers.value.length - 4 &&
                          hasMore.value &&
                          !isLoadingMore.value &&
                          !pageAsync.isLoading) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          isLoadingMore.value = true;
                          currentPage.value = currentPage.value + 1;
                        });
                      }
                      return _DashboardMemberCard(
                        dashboardMember: allMembers.value[index],
                      );
                    },
                    childCount: allMembers.value.length,
                  ),
                );
              },
            ),
          ),
        ],
        // Loading indicator while fetching next page
        if (hasMore.value && (isLoadingMore.value || pageAsync.isLoading))
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

/// A card showing a member's photo with an expiration badge overlay
/// and their name below.
class _DashboardMemberCard extends StatelessWidget {
  const _DashboardMemberCard({required this.dashboardMember});

  final DashboardMember dashboardMember;

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
        onTap: () => MemberDetailRoute(id: dashboardMember.id).go(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImage(
                      imageUrl: _thumbnailUrl(dashboardMember.photo)),
                  if (isExpired)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _DaysLeftBadge(days: 0),
                    )
                  else if (days != null && days <= 7)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _DaysLeftBadge(days: days),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Text(
                    dashboardMember.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dashboardMember.membershipEndDate != null
                        ? DateFormat('MMM d, y')
                            .format(dashboardMember.membershipEndDate!)
                        : 'No membership',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isExpired
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact badge showing how many days are left until expiration.
class _DaysLeftBadge extends StatelessWidget {
  const _DaysLeftBadge({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color backgroundColor;

    if (days == null) {
      label = 'No membership';
      backgroundColor = Colors.grey.shade700;
    } else if (days! <= 0) {
      label = 'Expired';
      backgroundColor = Colors.red.shade700;
    } else if (days == 1) {
      label = '1 day left';
      backgroundColor = Colors.red.shade700;
    } else {
      label = '$days days left';
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
