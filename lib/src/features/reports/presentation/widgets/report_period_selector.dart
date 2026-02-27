import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/report_period.dart';
import '../controllers/report_period_controller.dart';

/// Widget for selecting the report time period using outlined chips.
class ReportPeriodSelector extends ConsumerWidget {
  const ReportPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(reportPeriodControllerProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportPeriod.values.map((period) {
        final isSelected = period == selectedPeriod;
        return ChoiceChip(
          label: Text(period.displayName),
          selected: isSelected,
          onSelected: (_) {
            ref
                .read(reportPeriodControllerProvider.notifier)
                .setPeriod(period);
          },
        );
      }).toList(),
    );
  }
}
