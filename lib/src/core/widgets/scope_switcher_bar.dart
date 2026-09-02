import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../permissions/current_user_permissions.dart';
import 'branch_switcher.dart';
import 'organization_switcher.dart';

/// Shared chrome for standalone switcher pills vs embedded scope bar segments.
Widget wrapSwitcherChrome({
  required Widget child,
  required ThemeData theme,
  required bool compact,
  required bool embedded,
}) {
  if (embedded) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 8,
      ),
      child: child,
    );
  }

  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 12,
      vertical: compact ? 4 : 8,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 12,
      vertical: compact ? 0 : 4,
    ),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

/// Compact org + branch selectors in a single row: Organization | Branch.
class ScopeSwitcherBar extends ConsumerWidget {
  const ScopeSwitcherBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canSwitch = ref.watch(canUseOrganizationSwitcherProvider);

    if (!canSwitch) {
      return const BranchSwitcher(compact: true);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: OrganizationSwitcher(compact: true, embedded: true),
          ),
          SizedBox(
            height: 28,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          const Expanded(
            child: BranchSwitcher(compact: true, embedded: true),
          ),
        ],
      ),
    );
  }
}
