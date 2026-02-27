import 'package:flutter/material.dart';

import 'organization_nav_panel.dart';

/// Empty state shown when no user or role is selected in tablet layout.
class EmptyOrganizationState extends StatelessWidget {
  const EmptyOrganizationState({
    super.key,
    required this.mode,
  });

  /// Current organization mode to determine the message.
  final OrganizationMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, title, subtitle) = switch (mode) {
      OrganizationMode.users => (
          Icons.person_outline,
          'Select a user',
          'Choose a user from the list to view details',
        ),
      OrganizationMode.roles => (
          Icons.admin_panel_settings_outlined,
          'Select a role',
          'Choose a role from the list to view permissions',
        ),
      OrganizationMode.branches => (
          Icons.store_outlined,
          'Select a branch',
          'Choose a branch from the list to view details',
        ),
    };

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
