import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/pos_group.dart';
import '../../domain/pos_group_item.dart';
import '../utils/cashier_grid_layout.dart';
import 'cashier_product_card.dart';

/// Displays POS groups as scrollable sections with sticky headers.
///
/// Each group becomes a section with a header and a grid of product cards.
/// Falls back gracefully if groups are empty.
class GroupedCashierView extends StatelessWidget {
  const GroupedCashierView({
    super.key,
    required this.groups,
    this.bottomPadding = 12,
  });

  final List<PosGroup> groups;

  /// Extra scroll padding under the last section (FAB / cart bar clearance).
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Center(child: Text('No groups configured'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final spacing = CashierGridLayout.spacing(width);

        return CustomScrollView(
          slivers: [
            for (final group in groups) ...[
              SliverToBoxAdapter(
                child: _GroupHeader(group: group),
              ),
              if (group.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Center(
                      child: Text(
                        'No items in this group',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: CashierGridLayout.padding(width),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          CashierGridLayout.maxCrossAxisExtent(width),
                      childAspectRatio:
                          CashierGridLayout.childAspectRatio(width),
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = group.items[index];
                        return _GroupItemCard(item: item);
                      },
                      childCount: group.items.length,
                    ),
                  ),
                ),
            ],
            SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
          ],
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final PosGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              group.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${group.items.length}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupItemCard extends ConsumerWidget {
  const _GroupItemCard({required this.item});

  final PosGroupItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.isProduct && item.product != null) {
      return CashierProductCard(product: item.product!);
    }
    return const SizedBox.shrink();
  }
}
