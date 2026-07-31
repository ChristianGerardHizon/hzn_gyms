import 'package:flutter/material.dart';

import 'system_nav_panel.dart';

/// Empty state shown when no item is selected in tablet layout.
class EmptySystemState extends StatelessWidget {
  const EmptySystemState({
    super.key,
    required this.mode,
  });

  /// Current system mode to determine the message.
  final SystemMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, title, subtitle) = switch (mode) {
      SystemMode.productCategories => (
          Icons.inventory_2_outlined,
          'Select a category',
          'Choose a category from the list to view details',
        ),
      SystemMode.quantityUnits => (
          Icons.straighten_outlined,
          'Select a unit',
          'Choose a quantity unit from the list to view details',
        ),
      SystemMode.printers => (
          Icons.print_outlined,
          'Select a printer',
          'Choose a printer from the list to view and configure',
        ),
      SystemMode.cashierGroups => (
          Icons.point_of_sale_outlined,
          'Select a group',
          'Choose a group from the list to view and manage items',
        ),
      SystemMode.appearance => (
          Icons.palette_outlined,
          'Appearance',
          'Customize app theme and colors',
        ),
      SystemMode.import => (
          Icons.file_upload_outlined,
          'Import Products',
          'Import products and categories from a CSV file',
        ),
      SystemMode.debug => (
          Icons.bug_report_outlined,
          'Debug',
          'Developer tools for testing RFID and other flows',
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
