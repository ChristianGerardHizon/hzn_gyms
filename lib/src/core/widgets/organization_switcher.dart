import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/organizations/presentation/controllers/organizations_controller.dart';
import '../i18n/strings.g.dart';
import '../permissions/current_user_permissions.dart';

/// Organization switcher for super-admins to change the active tenant.
class OrganizationSwitcher extends ConsumerWidget {
  const OrganizationSwitcher({super.key, this.compact = false});

  /// When true, uses tighter padding for the tablet/mobile top bar.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final permissions = ref.watch(currentUserPermissionsProvider).value;
    final canManage = permissions?.canManageOrganizations ?? false;

    if (!canManage) {
      return const SizedBox.shrink();
    }

    final currentOrgAsync = ref.watch(currentOrganizationControllerProvider);
    final organizationsAsync = ref.watch(organizationsControllerProvider);

    return currentOrgAsync.when(
      skipLoadingOnReload: true,
      data: (currentOrg) {
        return organizationsAsync.when(
          data: (organizations) {
            if (organizations.isEmpty) {
              return _OrganizationDisplay(
                label: t.organizations.noOrganization,
                compact: compact,
              );
            }

            final selectedId = organizations.any((o) => o.id == currentOrg?.id)
                ? currentOrg?.id
                : organizations.first.id;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
                vertical: compact ? 4 : 8,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
                vertical: compact ? 0 : 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedId,
                  isExpanded: true,
                  isDense: compact,
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  hint: Text(t.organizations.switchOrganization),
                  items: organizations
                      .map(
                        (org) => DropdownMenuItem(
                          value: org.id,
                          child: Row(
                            children: [
                              const Icon(Icons.apartment, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  org.effectiveDisplayName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(currentOrganizationControllerProvider.notifier)
                          .switchOrganization(value);
                    }
                  },
                ),
              ),
            );
          },
          loading: () => _OrganizationDisplay(
            label: t.common.loading,
            isLoading: true,
            compact: compact,
          ),
          error: (_, __) => _OrganizationDisplay(
            label: currentOrg?.effectiveDisplayName ??
                t.organizations.noOrganization,
            compact: compact,
          ),
        );
      },
      loading: () => _OrganizationDisplay(
        label: t.common.loading,
        isLoading: true,
        compact: compact,
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OrganizationDisplay extends StatelessWidget {
  const _OrganizationDisplay({
    required this.label,
    this.isLoading = false,
    this.compact = false,
  });

  final String label;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apartment,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
