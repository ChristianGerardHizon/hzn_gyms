import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../controllers/user_search_controller.dart';

/// Dialog for selecting which fields to include in user search.
class UserSearchFieldsDialog extends ConsumerWidget {
  const UserSearchFieldsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final selectedFields = ref.watch(userSearchFieldsProvider);

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
        child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    t.fields.searchFields,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(userSearchFieldsProvider.notifier).reset();
                    },
                    child: Text(t.common.reset),
                  ),
                ),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(t.common.done),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  Text(
                    t.fields.searchFieldsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field checkboxes
                  ...userSearchableFields.map((field) {
                    final isSelected = selectedFields.contains(field);
                    final isLastSelected =
                        isSelected && selectedFields.length == 1;

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: isLastSelected
                          ? null // Can't deselect the last field
                          : (_) => ref
                              .read(userSearchFieldsProvider.notifier)
                              .toggleField(field),
                      title: Text(_getFieldLabel(field, t)),
                      subtitle: isLastSelected
                          ? Text(
                              t.fields.atLeastOneRequired,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _getFieldLabel(String field, Translations t) {
    switch (field) {
      case 'name':
        return t.fields.name;
      case 'username':
        return t.fields.username;
      default:
        return field;
    }
  }
}

/// Shows the user search fields selection dialog.
void showUserSearchFieldsDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => const UserSearchFieldsDialog(),
  );
}
