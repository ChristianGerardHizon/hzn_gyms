import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/domain/branch.dart';
import '../../features/settings/domain/branch_color_preset.dart';
import '../../features/settings/presentation/controllers/branches_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';

/// Default copy when an action needs a concrete branch but "All" is selected.
const kSelectBranchForActionMessage =
    'This action cannot be done while viewing all branches. '
    'Select a branch first.';

/// Ensures a writable (concrete) branch is selected.
///
/// Returns `true` immediately when one is already set. Otherwise shows
/// [showSelectBranchForActionDialog]; on confirm switches branch and returns
/// `true`. Cancel / dismiss returns `false` and leaves the selection unchanged.
Future<bool> ensureWritableBranch(
  BuildContext context,
  WidgetRef ref, {
  String message = kSelectBranchForActionMessage,
}) async {
  if (ref.read(effectiveBranchIdForWriteProvider) != null) {
    return true;
  }

  final selectedId = await showSelectBranchForActionDialog(
    context,
    ref,
    message: message,
  );
  return selectedId != null;
}

/// Prompts the user to pick a concrete branch (pill chips) before an action.
///
/// Returns the selected branch id after switching, or `null` if cancelled.
Future<String?> showSelectBranchForActionDialog(
  BuildContext context,
  WidgetRef ref, {
  String message = kSelectBranchForActionMessage,
}) async {
  final controller = ref.read(currentBranchControllerProvider.notifier);
  final switchableIds = await controller.switchableBranchIds();
  final allBranches = await ref.read(branchesControllerProvider.future);
  final branches =
      allBranches.where((b) => switchableIds.contains(b.id)).toList();

  if (!context.mounted) return null;
  if (branches.isEmpty) return null;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SelectBranchForActionDialog(
      branches: branches,
      message: message,
      onConfirm: (branchId) async {
        await ref
            .read(currentBranchControllerProvider.notifier)
            .switchBranch(branchId);
      },
    ),
  );
}

/// Dialog body: message, branch pill selection, Cancel / Switch & continue.
class SelectBranchForActionDialog extends HookWidget {
  const SelectBranchForActionDialog({
    super.key,
    required this.branches,
    required this.onConfirm,
    this.message = kSelectBranchForActionMessage,
  });

  final List<Branch> branches;
  final Future<void> Function(String branchId) onConfirm;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedId = useState<String?>(null);
    final isSwitching = useState(false);

    Future<void> confirm() async {
      final id = selectedId.value;
      if (id == null || isSwitching.value) return;

      isSwitching.value = true;
      try {
        await onConfirm(id);
        if (context.mounted) {
          Navigator.of(context).pop(id);
        }
      } finally {
        if (context.mounted) {
          isSwitching.value = false;
        }
      }
    }

    return AlertDialog(
      icon: Icon(
        Icons.storefront_outlined,
        color: theme.colorScheme.primary,
        size: 48,
      ),
      title: const Text('Select a Branch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final branch in branches)
                _BranchChoicePill(
                  branch: branch,
                  selected: selectedId.value == branch.id,
                  onSelected: isSwitching.value
                      ? null
                      : () => selectedId.value = branch.id,
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSwitching.value
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedId.value == null || isSwitching.value
              ? null
              : confirm,
          child: isSwitching.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Switch & continue'),
        ),
      ],
    );
  }
}

class _BranchChoicePill extends StatelessWidget {
  const _BranchChoicePill({
    required this.branch,
    required this.selected,
    required this.onSelected,
  });

  final Branch branch;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = BranchColorPreset.resolveColor(
      branch.color,
      fallback: theme.colorScheme.tertiary,
    );

    return Tooltip(
      message: branch.name,
      child: FilterChip(
        selected: selected,
        showCheckmark: false,
        avatar: Icon(
          Icons.storefront_outlined,
          size: 16,
          color: selected ? theme.colorScheme.onPrimary : accent,
        ),
        label: Text(branch.pillLabel),
        selectedColor: accent,
        checkmarkColor: theme.colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: selected ? theme.colorScheme.onPrimary : accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(
          color: accent.withValues(alpha: selected ? 0.9 : 0.45),
          width: selected ? 1.5 : 1,
        ),
        backgroundColor: accent.withValues(alpha: 0.1),
        onSelected: onSelected == null ? null : (_) => onSelected!(),
      ),
    );
  }
}
