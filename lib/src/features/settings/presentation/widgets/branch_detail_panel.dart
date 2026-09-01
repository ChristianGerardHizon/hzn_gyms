import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/organization.routes.dart';
import '../../../../core/widgets/branch_code_pill.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/branch.dart';
import '../../domain/branch_color_preset.dart';
import '../controllers/branches_controller.dart';
import 'dialogs/branch_form_dialog.dart';

/// Detail panel for viewing a branch in tablet layout.
class BranchDetailPanel extends ConsumerWidget {
  const BranchDetailPanel({
    super.key,
    required this.branchId,
  });

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);

    // Find the branch from the list
    final branches = branchesAsync.value;
    final branch = branches?.cast<Branch?>().firstWhere(
      (b) => b?.id == branchId,
      orElse: () => null,
    );

    if (branchesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (branch == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Branch not found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(branch.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => const OrganizationBranchesRoute().go(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => showBranchFormDialog(context, branch: branch),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _handleDelete(context, ref, branch),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _BranchDetailsBody(branch: branch),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${branch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(branchesControllerProvider.notifier)
        .deleteBranch(branch.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, message: 'Branch deleted successfully');
        const OrganizationBranchesRoute().go(context);
      } else {
        showFormErrorDialog(
          context,
          errors: ['Failed to delete branch. Please try again.'],
        );
      }
    }
  }
}

/// Read-only body displaying branch details.
class _BranchDetailsBody extends StatelessWidget {
  const _BranchDetailsBody({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.store,
                      size: 32,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Details section
          Text(
            'Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.store,
                    label: 'Name',
                    value: branch.name,
                  ),
                  _DetailRow(
                    icon: Icons.tag,
                    label: 'Code',
                    valueWidget: BranchCodePill(
                      label: branch.pillLabel,
                      tooltip: branch.name,
                      color: BranchColorPreset.resolveColor(
                        branch.color,
                        fallback: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                  _DetailRow(
                    icon: Icons.palette_outlined,
                    label: 'Pill color',
                    value: BranchColorPreset.byId(branch.color)?.label ?? '—',
                  ),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: branchDetailValue(branch.address),
                  ),
                  _DetailRow(
                    icon: Icons.phone,
                    label: 'Contact Number',
                    value: branchDetailValue(branch.contactNumber),
                  ),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: 'Operating Hours',
                    value: branchDetailValue(branch.operatingHours),
                  ),
                  _DetailRow(
                    icon: Icons.timer_off,
                    label: 'Cut-off Time',
                    value: branchDetailValue(branch.cutOffTime),
                  ),
                  if (branch.created != null)
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: dateFormat.format(branch.created!.toLocal()),
                    ),
                  if (branch.updated != null)
                    _DetailRow(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: dateFormat.format(branch.updated!.toLocal()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single row displaying a detail item with icon, label, and value.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value!,
                      style: theme.textTheme.bodyMedium,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
