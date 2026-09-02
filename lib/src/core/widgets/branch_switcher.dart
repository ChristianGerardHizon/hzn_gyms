import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/domain/branch.dart';
import '../../features/settings/presentation/controllers/branches_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../i18n/strings.g.dart';
import 'scope_switcher_bar.dart';

/// Branch switcher widget for the sidebar/drawer and tablet bar.
///
/// - Admins: dropdown of all branches plus "All branches"
/// - Non-admins with multiple allowed branches: dropdown of allowed set
/// - Non-admins with one (or zero) branch: display-only
class BranchSwitcher extends HookConsumerWidget {
  const BranchSwitcher({
    super.key,
    this.compact = false,
    this.embedded = false,
  });

  /// When true, uses tighter padding for the tablet top bar.
  final bool compact;

  /// When true, omits outer pill chrome (used inside [ScopeSwitcherBar]).
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final currentBranchAsync = ref.watch(currentBranchControllerProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final viewingAll = ref.watch(viewingAllBranchesProvider);

    final canSwitchFuture = useMemoized(
      () =>
          ref.read(currentBranchControllerProvider.notifier).canSwitchBranch(),
      [currentBranchAsync, viewingAll],
    );
    final canSwitchSnapshot = useFuture(canSwitchFuture);

    final canViewAllFuture = useMemoized(
      () => ref
          .read(currentBranchControllerProvider.notifier)
          .canViewAllBranches(),
      [currentBranchAsync, viewingAll],
    );
    final canViewAllSnapshot = useFuture(canViewAllFuture);

    final switchableIdsFuture = useMemoized(
      () => ref
          .read(currentBranchControllerProvider.notifier)
          .switchableBranchIds(),
      [currentBranchAsync, viewingAll],
    );
    final switchableIdsSnapshot = useFuture(switchableIdsFuture);

    return currentBranchAsync.when(
      // Keep showing the current branch while switching instead of collapsing
      // the switcher into a spinner.
      skipLoadingOnReload: true,
      data: (selection) {
        final currentBranch = selection.branch;
        final canSwitch = canSwitchSnapshot.data ?? false;
        final showAllOption = canViewAllSnapshot.data ?? false;
        final switchableIds = switchableIdsSnapshot.data;
        final viewingAllSelection = selection.isAll || viewingAll;
        final preferDropdown =
            canSwitch || (viewingAllSelection && showAllOption);

        if (!preferDropdown) {
          if (currentBranch == null) {
            return _NoBranchDisplay(
              theme: theme,
              compact: compact,
              embedded: embedded,
            );
          }
          return _BranchDisplay(
            branch: currentBranch,
            compact: compact,
            embedded: embedded,
          );
        }

        return branchesAsync.when(
          data: (allBranches) {
            // Wait for allowed IDs — never fall back to every branch (leaks
            // branches non-admins should not see).
            final ids = switchableIds;
            if (ids == null) {
              if (viewingAllSelection && showAllOption) {
                return _BranchDropdown(
                  compact: compact,
                  embedded: embedded,
                  selectedValue: allBranchesSentinel,
                  showAllOption: showAllOption,
                  allLabel: t.navigation.allBranches,
                  branches: const [],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(currentBranchControllerProvider.notifier)
                          .switchBranch(value);
                    }
                  },
                );
              }
              return currentBranch != null
                  ? _BranchDisplay(
                      branch: currentBranch,
                      isLoading: true,
                      compact: compact,
                      embedded: embedded,
                    )
                  : _BranchLoadingState(embedded: embedded);
            }

            final options = allBranches
                .where((b) => ids.contains(b.id))
                .toList();

            if (options.isEmpty && !showAllOption) {
              return _NoBranchDisplay(
                theme: theme,
                compact: compact,
                embedded: embedded,
              );
            }

            final selectedValue = viewingAllSelection
                ? allBranchesSentinel
                : currentBranch?.id;

            return _BranchDropdown(
              compact: compact,
              embedded: embedded,
              selectedValue: selectedValue,
              showAllOption: showAllOption,
              allLabel: t.navigation.allBranches,
              branches: options,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(currentBranchControllerProvider.notifier)
                      .switchBranch(value);
                }
              },
            );
          },
          loading: () {
            if (viewingAllSelection && showAllOption) {
              return _BranchDropdown(
                compact: compact,
                embedded: embedded,
                selectedValue: allBranchesSentinel,
                showAllOption: showAllOption,
                allLabel: t.navigation.allBranches,
                branches: const [],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(currentBranchControllerProvider.notifier)
                        .switchBranch(value);
                  }
                },
              );
            }
            return currentBranch != null
                ? _BranchDisplay(
                    branch: currentBranch,
                    isLoading: true,
                    compact: compact,
                    embedded: embedded,
                  )
                : _BranchLoadingState(embedded: embedded);
          },
          error: (_, __) {
            if (viewingAllSelection && showAllOption) {
              return _BranchDropdown(
                compact: compact,
                embedded: embedded,
                selectedValue: allBranchesSentinel,
                showAllOption: showAllOption,
                allLabel: t.navigation.allBranches,
                branches: const [],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(currentBranchControllerProvider.notifier)
                        .switchBranch(value);
                  }
                },
              );
            }
            return currentBranch != null
                ? _BranchDisplay(
                    branch: currentBranch,
                    compact: compact,
                    embedded: embedded,
                  )
                : _NoBranchDisplay(
                    theme: theme,
                    compact: compact,
                    embedded: embedded,
                  );
          },
        );
      },
      loading: () => _BranchLoadingState(embedded: embedded),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  const _BranchDropdown({
    required this.selectedValue,
    required this.branches,
    required this.onChanged,
    required this.showAllOption,
    required this.allLabel,
    this.compact = false,
    this.embedded = false,
  });

  final String? selectedValue;
  final List<Branch> branches;
  final ValueChanged<String?> onChanged;
  final bool showAllOption;
  final String allLabel;
  final bool compact;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = <DropdownMenuItem<String>>[
      if (showAllOption)
        DropdownMenuItem(
          value: allBranchesSentinel,
          child: Row(
            children: [
              const Icon(Icons.apps, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(allLabel, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ...branches.map((branch) {
        return DropdownMenuItem(
          value: branch.id,
          child: Row(
            children: [
              const Icon(Icons.store, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(branch.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      }),
    ];

    // Ensure dropdown value exists in items
    final values = items.map((e) => e.value).toSet();
    final value = selectedValue != null && values.contains(selectedValue)
        ? selectedValue
        : (showAllOption ? allBranchesSentinel : branches.firstOrNull?.id);

    return wrapSwitcherChrome(
      theme: theme,
      compact: compact,
      embedded: embedded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: compact,
          icon: const Icon(Icons.swap_horiz, size: 20),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BranchDisplay extends StatelessWidget {
  const _BranchDisplay({
    required this.branch,
    this.isLoading = false,
    this.compact = false,
    this.embedded = false,
  });

  final Branch branch;
  final bool isLoading;
  final bool compact;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return wrapSwitcherChrome(
      theme: theme,
      compact: compact,
      embedded: embedded,
      child: Row(
        children: [
          Icon(
            Icons.store,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              branch.name,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _NoBranchDisplay extends StatelessWidget {
  const _NoBranchDisplay({
    required this.theme,
    this.compact = false,
    this.embedded = false,
  });

  final ThemeData theme;
  final bool compact;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return wrapSwitcherChrome(
      theme: theme,
      compact: compact,
      embedded: embedded,
      child: Row(
        children: [
          Icon(
            Icons.store_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.navigation.noBranch,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchLoadingState extends StatelessWidget {
  const _BranchLoadingState({this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return wrapSwitcherChrome(
      theme: theme,
      compact: true,
      embedded: embedded,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
