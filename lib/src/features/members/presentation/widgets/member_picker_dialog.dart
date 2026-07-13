import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';

/// Shows a searchable dialog to pick a member.
///
/// Returns the selected [Member], or `null` if dismissed.
Future<Member?> showMemberPickerDialog(
  BuildContext context, {
  String title = 'Select Member',
  String? subtitle,
}) {
  return showConstrainedDialog<Member>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => MemberPickerDialog(
      title: title,
      subtitle: subtitle,
    ),
  );
}

/// Searchable member picker dialog.
class MemberPickerDialog extends HookConsumerWidget {
  const MemberPickerDialog({
    super.key,
    this.title = 'Select Member',
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final rawQuery = useState('');
    final debouncedQuery = useState('');
    final results = useState<List<Member>>([]);
    final isSearching = useState(false);
    final hasSearched = useState(false);

    useEffect(() {
      void listener() => rawQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    useEffect(() {
      if (rawQuery.value.trim().isEmpty) {
        debouncedQuery.value = '';
        results.value = [];
        hasSearched.value = false;
        return null;
      }
      final timer = Timer(const Duration(milliseconds: 400), () {
        debouncedQuery.value = rawQuery.value.trim();
      });
      return timer.cancel;
    }, [rawQuery.value]);

    useEffect(() {
      final query = debouncedQuery.value;
      if (query.isEmpty) return null;

      var cancelled = false;
      Future<void> runSearch() async {
        isSearching.value = true;
        hasSearched.value = true;
        final result = await ref.read(memberRepositoryProvider).search(query);
        if (cancelled) return;
        isSearching.value = false;
        result.fold(
          (_) => results.value = [],
          (members) => results.value = members,
        );
      }

      runSearch();
      return () => cancelled = true;
    }, [debouncedQuery.value]);

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
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name or phone...',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: rawQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
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
                  if (!hasSearched.value) {
                    return Center(
                      child: Text(
                        'Type a name or phone number to find a member',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (results.value.isEmpty) {
                    return Center(
                      child: Text(
                        'No members match "${debouncedQuery.value}"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.value.length,
                    itemBuilder: (context, index) {
                      final member = results.value[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(member.name),
                        subtitle: member.mobileNumber != null
                            ? Text(member.mobileNumber!)
                            : null,
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
