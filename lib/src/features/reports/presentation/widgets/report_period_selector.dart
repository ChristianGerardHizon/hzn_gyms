import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/report_period.dart';
import '../controllers/report_period_controller.dart';

/// Period grain chips + grain-specific From / To range pickers.
class ReportPeriodSelector extends ConsumerWidget {
  const ReportPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(reportPeriodControllerProvider);
    final notifier = ref.read(reportPeriodControllerProvider.notifier);
    final isMobile = Breakpoints.isMobile(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                selection.displayRangeLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: () => notifier.setPeriod(selection.period),
              icon: const Icon(Icons.today, size: 18),
              label: const Text('Current'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _PeriodChipBar(
          selection: selection,
          isMobile: isMobile,
          onSelected: notifier.setPeriod,
        ),
        SizedBox(height: isMobile ? 10 : 12),
        _RangePickerRow(selection: selection, isMobile: isMobile),
      ],
    );
  }
}

class _PeriodChipBar extends StatelessWidget {
  const _PeriodChipBar({
    required this.selection,
    required this.isMobile,
    required this.onSelected,
  });

  final ReportPeriodSelection selection;
  final bool isMobile;
  final ValueChanged<ReportPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = ReportPeriod.values.map((period) {
      final isSelected = period == selection.period;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(period.displayName),
          selected: isSelected,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (_) => onSelected(period),
        ),
      );
    }).toList();

    if (!isMobile) {
      return Wrap(children: chips);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }
}

class _RangePickerRow extends ConsumerWidget {
  const _RangePickerRow({
    required this.selection,
    required this.isMobile,
  });

  final ReportPeriodSelection selection;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reportPeriodControllerProvider.notifier);

    final startLabel = _formatStart(selection);
    final endLabel = _formatEnd(selection);

    Future<void> pickStart() async {
      final picked = await _pickForGrain(
        context,
        selection: selection,
        initial: selection.rangeStart,
        title: 'From',
      );
      if (picked != null) notifier.setRangeStart(picked);
    }

    Future<void> pickEnd() async {
      final picked = await _pickForGrain(
        context,
        selection: selection,
        initial: selection.rangeEnd,
        title: 'To',
      );
      if (picked != null) notifier.setRangeEnd(picked);
    }

    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: _RangeField(
              caption: 'From',
              label: startLabel,
              onPressed: pickStart,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RangeField(
              caption: 'To',
              label: endLabel,
              onPressed: pickEnd,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text('From', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 8),
        _RangeButton(label: startLabel, onPressed: pickStart),
        const SizedBox(width: 16),
        Text('To', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 8),
        _RangeButton(label: endLabel, onPressed: pickEnd),
      ],
    );
  }

  String _formatStart(ReportPeriodSelection selection) {
    switch (selection.period) {
      case ReportPeriod.day:
        return DateFormat('MMM d, y').format(selection.rangeStart);
      case ReportPeriod.weekly:
        return DateFormat('MMM d, y').format(
          startOfWeekMonday(selection.rangeStart),
        );
      case ReportPeriod.monthly:
        return DateFormat('MMM y').format(selection.rangeStart);
      case ReportPeriod.yearly:
      case ReportPeriod.allTime:
        return selection.rangeStart.year.toString();
    }
  }

  String _formatEnd(ReportPeriodSelection selection) {
    switch (selection.period) {
      case ReportPeriod.day:
        return DateFormat('MMM d, y').format(selection.rangeEnd);
      case ReportPeriod.weekly:
        return DateFormat('MMM d, y').format(
          endOfWeekSunday(selection.rangeEnd),
        );
      case ReportPeriod.monthly:
        return DateFormat('MMM y').format(selection.rangeEnd);
      case ReportPeriod.yearly:
      case ReportPeriod.allTime:
        return selection.rangeEnd.year.toString();
    }
  }
}

/// Mobile range control: caption above a full-width outlined button.
class _RangeField extends StatelessWidget {
  const _RangeField({
    required this.caption,
    required this.label,
    required this.onPressed,
  });

  final String caption;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          caption,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.calendar_month, size: 16),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_month, size: 18),
      label: Text(label),
    );
  }
}

Future<DateTime?> _pickForGrain(
  BuildContext context, {
  required ReportPeriodSelection selection,
  required DateTime initial,
  required String title,
}) {
  switch (selection.period) {
    case ReportPeriod.day:
      return showDatePicker(
        context: context,
        initialDate: startOfDay(initial),
        firstDate: DateTime(2019),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: '$title date',
      );
    case ReportPeriod.weekly:
      return showDatePicker(
        context: context,
        initialDate: startOfDay(initial),
        firstDate: DateTime(2019),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: '$title week (pick any day)',
      );
    case ReportPeriod.monthly:
      return _showMonthYearPicker(
        context,
        initial: initial,
        title: '$title month',
      );
    case ReportPeriod.yearly:
    case ReportPeriod.allTime:
      return _showYearPicker(
        context,
        initial: initial,
        title: '$title year',
      );
  }
}

Future<DateTime?> _showMonthYearPicker(
  BuildContext context, {
  required DateTime initial,
  required String title,
}) async {
  var year = initial.year;
  var month = initial.month;
  final now = DateTime.now();
  if (year < 2019) year = 2019;
  if (year > now.year) year = now.year;
  final years = List.generate(now.year - 2018, (i) => 2019 + i);

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('month-$month'),
                    initialValue: month,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: List.generate(12, (i) {
                      final m = i + 1;
                      return DropdownMenuItem(
                        value: m,
                        child: Text(DateFormat('MMMM').format(DateTime(2000, m))),
                      );
                    }),
                    onChanged: (v) {
                      if (v != null) setState(() => month = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('year-$year'),
                    initialValue: year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: years
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => year = v);
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, DateTime(year, month)),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<DateTime?> _showYearPicker(
  BuildContext context, {
  required DateTime initial,
  required String title,
}) async {
  var year = initial.year;
  final now = DateTime.now();
  if (year < 2019) year = 2019;
  if (year > now.year) year = now.year;
  final years = List.generate(now.year - 2018, (i) => 2019 + i);

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: DropdownButtonFormField<int>(
              key: ValueKey('year-$year'),
              initialValue: year,
              decoration: const InputDecoration(labelText: 'Year'),
              items: years
                  .map(
                    (y) => DropdownMenuItem(
                      value: y,
                      child: Text('$y'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => year = v);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, DateTime(year)),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}
