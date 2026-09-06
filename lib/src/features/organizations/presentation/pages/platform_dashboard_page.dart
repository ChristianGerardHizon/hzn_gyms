import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/platform.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../controllers/platform_dashboard_controller.dart';
import '../widgets/organization_form_dialog.dart';
import '../widgets/organization_list_tile.dart';

/// Platform super-admin home — tenant summary and quick actions.
class PlatformDashboardPage extends ConsumerWidget {
  const PlatformDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final summaryAsync = ref.watch(platformDashboardSummaryProvider);
    final recentAsync = ref.watch(platformRecentOrganizationsProvider);
    final isMobile = Breakpoints.isMobile(context);
    final pad = isMobile ? 16.0 : 24.0;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(platformDashboardSummaryProvider);
        ref.invalidate(platformRecentOrganizationsProvider);
      },
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          Text(
            t.organizations.platformDashboard,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          summaryAsync.when(
            data: (summary) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  label: t.organizations.summaryTotal,
                  value: '${summary.total}',
                  icon: Icons.business,
                ),
                _SummaryCard(
                  label: t.organizations.summaryPendingSetup,
                  value: '${summary.pendingSetup}',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _SummaryCard(
                  label: t.organizations.summaryDnsIssues,
                  value: '${summary.dnsIssues}',
                  icon: Icons.dns,
                  color: Colors.red,
                ),
                _SummaryCard(
                  label: t.organizations.summaryReady,
                  value: '${summary.ready}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => showOrganizationFormDialog(context),
                icon: const Icon(Icons.add),
                label: Text(t.organizations.create),
              ),
              OutlinedButton.icon(
                onPressed: () => const PlatformOrganizationsRoute().go(context),
                icon: const Icon(Icons.list),
                label: Text(t.organizations.viewAllOrganizations),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            t.organizations.recentOrganizations,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          recentAsync.when(
            data: (orgs) {
              if (orgs.isEmpty) {
                return Text(t.organizations.emptyList);
              }
              return Column(
                children: [
                  for (final org in orgs)
                    OrganizationListTile(organization: org),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color ?? theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
