import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart';

/// Compact start/end period card used by purchase and renew flows.
///
/// When [isDateCustomized] and the chosen dates differ from the defaults,
/// the original dates are shown with a strikethrough so the change is obvious.
class MembershipPeriodPreview extends StatelessWidget {
  const MembershipPeriodPreview({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.defaultStartDate,
    required this.defaultEndDate,
    required this.isDateCustomized,
    required this.isStacking,
    this.currentMembershipEndDate,
    this.bonusDays = 0,
    required this.onChangeStartDate,
    this.onResetToDefault,
    this.enabled = true,
  });

  final DateTime startDate;
  final DateTime endDate;
  final DateTime defaultStartDate;
  final DateTime defaultEndDate;
  final bool isDateCustomized;
  final bool isStacking;
  final DateTime? currentMembershipEndDate;
  final int bonusDays;
  final VoidCallback onChangeStartDate;
  final VoidCallback? onResetToDefault;
  final bool enabled;

  bool get _datesDifferFromDefault =>
      toLocalDateOnly(startDate) != toLocalDateOnly(defaultStartDate) ||
      toLocalDateOnly(endDate) != toLocalDateOnly(defaultEndDate);

  bool get _showStrikeout => isDateCustomized && _datesDifferFromDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    final title = isStacking && !isDateCustomized
        ? 'Starts after current membership'
        : 'Membership period';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: _showStrikeout
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.45),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (_showStrikeout)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    'Dates changed',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              TextButton(
                onPressed: enabled ? onChangeStartDate : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PeriodDateColumn(
                  label: 'Start',
                  date: startDate,
                  struckDate: _showStrikeout ? defaultStartDate : null,
                  dateFormat: dateFormat,
                  icon: Icons.event,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _PeriodDateColumn(
                  label: 'End',
                  date: endDate,
                  struckDate: _showStrikeout ? defaultEndDate : null,
                  dateFormat: dateFormat,
                  icon: Icons.event_available,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (bonusDays > 0) ...[
            const SizedBox(height: 10),
            Text(
              'Includes ${bonusDays == 1 ? '1 extra day' : '$bonusDays extra days'} from add-ons',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (isStacking && currentMembershipEndDate != null) ...[
            const SizedBox(height: 6),
            Text(
              'Current membership ends ${dateFormat.format(currentMembershipEndDate!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (isDateCustomized && isStacking && onResetToDefault != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: enabled ? onResetToDefault : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Use day after current membership'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodDateColumn extends StatelessWidget {
  const _PeriodDateColumn({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.icon,
    this.struckDate,
    this.alignEnd = false,
  });

  final String label;
  final DateTime date;
  final DateTime? struckDate;
  final DateFormat dateFormat;
  final IconData icon;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxis = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!alignEnd) ...[
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (alignEnd) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: theme.colorScheme.primary),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (struckDate != null)
          Text(
            dateFormat.format(struckDate!),
            textAlign: textAlign,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              decorationColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        Text(
          dateFormat.format(date),
          textAlign: textAlign,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: struckDate != null ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
