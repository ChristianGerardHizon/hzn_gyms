import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../products/presentation/widgets/dialogs/create_product_dialog.dart';

/// Step 6 — optional product for POS (skippable).
class OrganizationSetupOptionalProductStep extends ConsumerWidget {
  const OrganizationSetupOptionalProductStep({
    super.key,
    required this.onCreated,
    required this.onSkip,
  });

  final VoidCallback onCreated;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.organizations.setupProductHint),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            await showDialog<void>(
              context: context,
              builder: (context) => const CreateProductDialog(),
            );
            onCreated();
          },
          icon: const Icon(Icons.inventory_2),
          label: Text(t.organizations.setupCreateProduct),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onSkip,
          child: Text(t.organizations.setupSkipStep),
        ),
      ],
    );
  }
}
