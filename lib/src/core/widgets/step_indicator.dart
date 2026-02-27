import 'package:flutter/material.dart';

/// A step indicator showing numbered circles with connecting lines.
///
/// Completed steps show checkmarks, the current step is highlighted,
/// and future steps are grayed out.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  /// The zero-based index of the current step.
  final int currentStep;

  /// Labels for each step.
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i <= currentStep
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentStep
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
                child: Center(
                  child: i < currentStep
                      ? Icon(Icons.check,
                          size: 16, color: theme.colorScheme.onPrimary)
                      : Text(
                          '${i + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: i == currentStep
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < steps.length; i++)
              SizedBox(
                width: 60,
                child: Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: i <= currentStep
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        i == currentStep ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
