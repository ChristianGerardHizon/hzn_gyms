import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';

/// Summary chip data for the KPI breakdown header strip.
class KpiSummaryChipData {
  const KpiSummaryChipData({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;
}

/// Opens a constrained KPI breakdown dialog.
Future<void> showKpiBreakdownDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  List<Widget>? actions,
  required Widget Function(BuildContext context, WidgetRef ref) bodyBuilder,
}) {
  return showConstrainedDialog<void>(
    context: context,
    maxWidth: DialogConstraints.defaultMaxWidth,
    barrierDismissible: true,
    builder: (context) => KpiBreakdownDialog(
      title: title,
      subtitle: subtitle,
      actions: actions,
      bodyBuilder: bodyBuilder,
    ),
  );
}

/// Reusable shell: header, optional actions, and an async-aware list body.
class KpiBreakdownDialog extends ConsumerWidget {
  const KpiBreakdownDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.bodyBuilder,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget Function(BuildContext context, WidgetRef ref) bodyBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.defaultMaxWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: bodyBuilder(context, ref)),
          ],
        ),
      ),
    );
  }
}

/// Horizontal strip of summary chips.
class KpiSummaryChipRow extends StatelessWidget {
  const KpiSummaryChipRow({super.key, required this.chips});

  final List<KpiSummaryChipData> chips;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            KpiSummaryChip(data: chips[i]),
          ],
        ],
      ),
    );
  }
}

/// A single summary chip showing a label and value.
class KpiSummaryChip extends StatelessWidget {
  const KpiSummaryChip({super.key, required this.data});

  final KpiSummaryChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = data.color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared loading / empty / error / list layout for KPI breakdown bodies.
class KpiBreakdownListBody<T> extends StatelessWidget {
  const KpiBreakdownListBody({
    super.key,
    required this.asyncValue,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.itemBuilder,
    this.summaryBuilder,
    this.summaryHeaderBuilder,
    this.listHeader,
    this.onRetry,
    this.separatorBuilder,
  }) : assert(
          summaryBuilder != null || summaryHeaderBuilder != null,
          'Provide summaryBuilder and/or summaryHeaderBuilder',
        );

  final AsyncValue<List<T>> asyncValue;
  final String emptyMessage;
  final IconData emptyIcon;

  /// Horizontal chip strip (used when [summaryHeaderBuilder] is null).
  final List<KpiSummaryChipData> Function(List<T> items)? summaryBuilder;

  /// Custom summary header; takes precedence over [summaryBuilder].
  final Widget Function(List<T> items)? summaryHeaderBuilder;

  /// Optional label/row above the scrollable list (e.g. "Transactions").
  final Widget? listHeader;

  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load data',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    emptyIcon,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final summary = summaryHeaderBuilder != null
            ? summaryHeaderBuilder!(items)
            : KpiSummaryChipRow(chips: summaryBuilder!(items));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            summary,
            const Divider(height: 1),
            if (listHeader != null) listHeader!,
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder:
                    separatorBuilder ?? (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    itemBuilder(context, items[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}
