import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/branches.routes.dart';
import '../../domain/branch.dart';
import '../controllers/branches_controller.dart';
import '../widgets/dialogs/branch_form_dialog.dart';
import '../widgets/empty_branch_detail_state.dart';

/// Two-pane tablet layout for branches.
class TabletBranchesLayout extends HookConsumerWidget {
  const TabletBranchesLayout({super.key, required this.detailChild});

  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final routerState = GoRouterState.of(context);
    final selectedId = routerState.pathParameters['id'];
    final branchesAsync = ref.watch(branchesControllerProvider);
    final controller = ref.read(branchesControllerProvider.notifier);

    final searchController = useTextEditingController();
    final searchText = useState('');
    final query = searchText.value.trim();
    final isSearchActive = query.isNotEmpty;

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              heroTag: 'branch_fab',
              onPressed: () => showBranchFormDialog(context),
              tooltip: 'Add Branch',
              child: const Icon(Icons.add),
            ),
            body: branchesAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
              data: (branches) {
                final filteredBranches = isSearchActive
                    ? _filterBranches(branches, query)
                    : branches;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Row(
                        children: [
                          Text(
                            t.navigation.branches,
                            style: theme.textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${filteredBranches.length} total',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: searchController,
                        onChanged: (text) => searchText.value = text,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: '${t.common.search}...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchText.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    searchText.value = '';
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                          filled: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.refresh(),
                        child: filteredBranches.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 80),
                                  Icon(
                                    Icons.store_outlined,
                                    size: 80,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isSearchActive
                                        ? 'No branches match "$query"'
                                        : 'No branches yet',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: filteredBranches.length,
                                itemBuilder: (context, index) {
                                  final branch = filteredBranches[index];
                                  final isSelected = branch.id == selectedId;

                                  return ListTile(
                                    selected: isSelected,
                                    selectedTileColor: theme
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.3),
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected
                                          ? theme.colorScheme.primary
                                          : theme
                                              .colorScheme
                                              .primaryContainer,
                                      child: Icon(
                                        Icons.store_outlined,
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                      ),
                                    ),
                                    title: Text(branch.name),
                                    subtitle: Text(
                                      branch.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => BranchDetailRoute(id: branch.id)
                                        .go(context),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: selectedId != null
              ? detailChild
              : const EmptyBranchDetailState(),
        ),
      ],
    );
  }
}

List<Branch> _filterBranches(List<Branch> branches, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return branches;
  }

  return branches.where((b) {
    final nameMatch = b.name.toLowerCase().contains(normalizedQuery);
    final addressMatch = b.address.toLowerCase().contains(normalizedQuery);
    return nameMatch || addressMatch;
  }).toList();
}
