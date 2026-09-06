import 'package:flutter/material.dart';

import '../../domain/organization.dart';

/// Badge showing tenant onboarding status on org list tiles.
class OrganizationSetupStatusBadge extends StatelessWidget {
  const OrganizationSetupStatusBadge({super.key, required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = organization.setupStatus.isReady;
    final color = isReady ? Colors.green : Colors.orange;
    final label = isReady ? 'Ready' : 'Pending setup';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
