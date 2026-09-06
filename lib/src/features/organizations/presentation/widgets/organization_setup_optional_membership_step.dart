import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../memberships/presentation/widgets/membership_form_dialog.dart';

/// Step 5 — optional membership plan (skippable).
class OrganizationSetupOptionalMembershipStep extends ConsumerWidget {
  const OrganizationSetupOptionalMembershipStep({
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
        Text(t.organizations.setupMembershipHint),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            final saved = await showMembershipFormDialog(context);
            if (saved == true) onCreated();
          },
          icon: const Icon(Icons.card_membership),
          label: Text(t.organizations.setupCreateMembership),
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
