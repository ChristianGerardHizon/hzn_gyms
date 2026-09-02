import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/platform.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../domain/organization.dart';
import '../controllers/current_organization_controller.dart';
import 'organization_dns_retry_button.dart';
import 'organization_form_dialog.dart';
import 'organization_setup_status_badge.dart';

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
        leading: CachedAvatar(
          imageUrl: organization.logoTransparentUrl,
          radius: 22,
          placeholderIcon: Icons.apartment,
          thumbSize: 88,
        ),
        title: Text(organization.effectiveDisplayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slug: ${organization.slug}'),
            if (organization.subdomain != null &&
                organization.subdomain!.isNotEmpty)
              Text(organization.subdomain!),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OrganizationSetupStatusBadge(organization: organization),
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
            if (!organization.setupStatus.isReady)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () {
                    OrganizationSetupRoute(orgId: organization.id).go(context);
                  },
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text(t.organizations.continueSetup),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (organization.setupStatus.isReady)
              IconButton(
                tooltip: t.organizations.enterTenant,
                icon: const Icon(Icons.login),
                onPressed: () async {
                  await ref
                      .read(currentOrganizationControllerProvider.notifier)
                      .switchOrganization(organization.id);
                },
              ),
            OrganizationDnsRetryButton(organization: organization),
          ],
        ),
        onTap: () => showOrganizationFormDialog(
          context,
          organization: organization,
        ),
      ),
    );
  }
}
