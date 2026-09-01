import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../domain/organization.dart';
import 'organization_dns_retry_button.dart';
import 'organization_form_dialog.dart';

/// List tile for a single organization in the management screen.
class OrganizationListTile extends ConsumerWidget {
  const OrganizationListTile({super.key, required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final dnsStatus = organization.dnsStatus;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(organization.effectiveDisplayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slug: ${organization.slug}'),
            if (organization.subdomain != null &&
                organization.subdomain!.isNotEmpty)
              Text(organization.subdomain!),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${t.organizations.dnsStatus}: '),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: dnsStatus.badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dnsStatus.badgeColor),
                  ),
                  child: Text(
                    dnsStatus.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: dnsStatus.badgeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (organization.dnsError != null &&
                organization.dnsError!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  organization.dnsError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: OrganizationDnsRetryButton(organization: organization),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (context) =>
                OrganizationFormDialog(organization: organization),
          );
        },
      ),
    );
  }
}
