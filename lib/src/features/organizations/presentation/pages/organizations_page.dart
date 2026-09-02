import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../controllers/organizations_controller.dart';
import '../widgets/organization_form_dialog.dart';
import '../widgets/organization_list_tile.dart';

/// Super-admin page for listing and managing organizations.
class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final organizationsAsync = ref.watch(organizationsControllerProvider);
    final isMobile = Breakpoints.isMobile(context);
    final horizontalPad = isMobile ? 16.0 : 24.0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showOrganizationFormDialog(context),
        icon: const Icon(Icons.add),
        label: Text(t.organizations.create),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              isMobile ? 12 : 20,
              horizontalPad,
              isMobile ? 4 : 8,
            ),
            child: Text(
              t.organizations.title,
              style:
                  (isMobile
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.headlineMedium)
                      ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: organizationsAsync.when(
              data: (organizations) {
                if (organizations.isEmpty) {
                  return Center(child: Text(t.organizations.emptyList));
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(organizationsControllerProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    itemCount: organizations.length,
                    itemBuilder: (context, index) {
                      return OrganizationListTile(
                        organization: organizations[index],
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(organizationsControllerProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
