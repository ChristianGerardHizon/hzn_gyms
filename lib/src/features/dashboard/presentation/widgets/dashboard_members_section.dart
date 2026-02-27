import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../controllers/dashboard_members_controller.dart';

/// Number of members to show initially and per "load more" batch.
const _pageSize = 20;

/// Section displaying all members as a grid of photo cards on the dashboard.
///
/// Shows near-expiration members first. Includes search and lazy loading.
class DashboardMembersSection extends HookConsumerWidget {
  const DashboardMembersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(dashboardMembersProvider);
    final searchQuery = useState('');
    final visibleCount = useState(_pageSize);

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) return const SizedBox.shrink();

        // Filter by search query
        final filtered = searchQuery.value.isEmpty
            ? members
            : members.where((dm) {
                final query = searchQuery.value.toLowerCase();
                return dm.member.name.toLowerCase().contains(query);
              }).toList();

        // Paginate
        final visible = filtered.take(visibleCount.value).toList();
        final hasMore = filtered.length > visibleCount.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${members.length}',
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
                  searchQuery.value = value;
                  // Reset pagination when search changes
                  visibleCount.value = _pageSize;
                },
              ),
              const SizedBox(height: 12),
              // Member photo grid
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No members found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth > 600 ? 4 : 3;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        return _DashboardMemberCard(
                          dashboardMember: visible[index],
                        );
                      },
                    );
                  },
                ),
              // Load more button
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        visibleCount.value += _pageSize;
                      },
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: Text(
                        'Show more (${filtered.length - visibleCount.value} remaining)',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// A card showing a member's photo with an expiration badge overlay
/// and their name below.
class _DashboardMemberCard extends StatelessWidget {
  const _DashboardMemberCard({required this.dashboardMember});

  final DashboardMember dashboardMember;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = dashboardMember.member;
    final membership = dashboardMember.activeMembership;
    final latestMembership = dashboardMember.latestMembership;
    final days = dashboardMember.daysUntilExpiry;
    final isExpired = dashboardMember.isExpired;

    // Determine which membership to show date for
    final displayMembership = membership ?? latestMembership;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpired
            ? BorderSide(color: theme.colorScheme.error, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => MemberDetailRoute(id: member.id).go(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo with days left badge overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImage(imageUrl: member.photo),
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
            // Member name and expiry date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayMembership?.endDate != null
                        ? DateFormat('MMM d, y')
                            .format(displayMembership!.endDate)
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
      backgroundColor = days! <= 3 ? Colors.red.shade700 : Colors.orange.shade700;
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
