import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/utils/search_tokens.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/local/member_local_data_source.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';
import '../controllers/member_branch_activity_controller.dart';
import 'member_branch_activity_chips.dart';
import 'member_form_dialog.dart';

/// Shows a searchable dialog to pick a member.
///
/// Returns the selected [Member], or `null` if dismissed.
Future<Member?> showMemberPickerDialog(
  BuildContext context, {
  String title = 'Select Member',
  String? subtitle,
  bool showBranchActivity = false,
  bool allowCreateOnEmpty = false,
}) {
  return showConstrainedDialog<Member>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => MemberPickerDialog(
      title: title,
      subtitle: subtitle,
      showBranchActivity: showBranchActivity,
      allowCreateOnEmpty: allowCreateOnEmpty,
    ),
  );
}

/// Searchable member picker dialog.
class MemberPickerDialog extends HookConsumerWidget {
  const MemberPickerDialog({
    super.key,
    this.title = 'Select Member',
    this.subtitle,
    this.showBranchActivity = false,
    this.allowCreateOnEmpty = false,
  });

  final String title;
  final String? subtitle;
  final bool showBranchActivity;
  final bool allowCreateOnEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final rawQuery = useState('');
    final debouncedQuery = useState('');
    final results = useState<List<Member>>([]);
    final isSearching = useState(false);
    final hasSearched = useState(false);
    const searchFields = ['name', 'mobileNumber'];

    final memberIds = results.value.map((m) => m.id).toList();
    final activityAsync = showBranchActivity && memberIds.isNotEmpty
        ? ref.watch(
            memberBranchActivityForIdsProvider(
              memberBranchActivityIdsKey(memberIds),
            ),
          )
        : null;
    final currentBranchId = ref.watch(currentBranchIdProvider);

    // Dialog transitions often steal autofocus; re-request after the first frame.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (searchFocusNode.canRequestFocus) {
          searchFocusNode.requestFocus();
        }
      });
      return null;
    }, [searchFocusNode]);

    useEffect(() {
      void listener() => rawQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final debouncedSearch = useDebouncedCallback<String>((query) {
      debouncedQuery.value = query.trim();
    });

    useEffect(() {
      final trimmed = rawQuery.value.trim();
      debouncedSearch.cancel();
      if (trimmed.isEmpty) {
        debouncedQuery.value = '';
        return null;
      }
      debouncedSearch.call(rawQuery.value);
      return null;
    }, [rawQuery.value]);

    useEffect(() {
      final query = debouncedQuery.value;
      if (!isMemberSearchQueryReady(query)) {
        if (query.isEmpty) {
          results.value = [];
          hasSearched.value = false;
        }
        isSearching.value = false;
        return null;
      }

      var cancelled = false;
      Future<void> runSearch() async {
        isSearching.value = true;
        hasSearched.value = true;

        final local = ref.read(memberLocalDataSourceProvider);
        final cached = await local.searchQuick(
          query,
          fields: searchFields,
          limit: Pagination.memberPickerSearchLimit,
        );
        if (cancelled) return;
        if (cached.isNotEmpty) {
          results.value = cached;
          isSearching.value = false;
        }

        final result = await ref.read(memberRepositoryProvider).searchQuick(
              query,
              fields: searchFields,
              limit: Pagination.memberPickerSearchLimit,
            );
        if (cancelled) return;
        isSearching.value = false;
        result.fold(
          (_) {
            if (results.value.isEmpty) results.value = [];
          },
          (members) => results.value = members,
        );
      }

      runSearch();
      return () => cancelled = true;
    }, [debouncedQuery.value]);

    Future<void> createNewMember() async {
      final query = searchController.text.trim();
      Navigator.of(context).pop();
      if (!context.mounted) return;
      final result = await showMemberFormDialog(
        context,
        initialName: query.isEmpty ? null : query,
      );
      if (context.mounted) {
        await handleMemberFormPaymentResult(context, ref, result);
      }
    }

    Widget? buildSuffixIcon() {
      final showClear = rawQuery.value.isNotEmpty;
      if (!allowCreateOnEmpty && !showClear) return null;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showClear)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => searchController.clear(),
              tooltip: 'Clear',
            ),
          if (allowCreateOnEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: createNewMember,
              tooltip: 'Create new member',
            ),
        ],
      );
    }

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleLarge),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name or phone...',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: buildSuffixIcon(),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isSearching.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!hasSearched.value ||
                      !isMemberSearchQueryReady(rawQuery.value.trim())) {
                    return Center(
                      child: Text(
                        rawQuery.value.trim().isNotEmpty &&
                                !isMemberSearchQueryReady(rawQuery.value.trim())
                            ? 'Type at least 2 characters to search'
                            : 'Type a name or phone number to find a member',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (results.value.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No members match "${debouncedQuery.value}"',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (allowCreateOnEmpty &&
                                debouncedQuery.value.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: createNewMember,
                                icon: const Icon(Icons.person_add),
                                label: const Text('Create new member'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.value.length,
                    itemBuilder: (context, index) {
                      final member = results.value[index];
                      final activity = activityAsync?.maybeWhen(
                        data: (state) => state.activityByMemberId[member.id],
                        orElse: () => null,
                      );
                      final branchNameById = activityAsync?.maybeWhen(
                        data: (state) => state.branchNameById,
                        orElse: () => const <String, String>{},
                      ) ?? const <String, String>{};
                      final activityLoading = showBranchActivity &&
                          (activityAsync?.isLoading ?? false);

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(member.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (member.mobileNumber != null)
                              Text(member.mobileNumber!),
                            if (showBranchActivity) ...[
                              if (member.mobileNumber != null)
                                const SizedBox(height: 6),
                              MemberBranchActivityChips(
                                activity: activity,
                                branchNameById: branchNameById,
                                currentBranchId: currentBranchId,
                                isLoading: activityLoading,
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: showBranchActivity,
                        onTap: () => Navigator.of(context).pop(member),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
