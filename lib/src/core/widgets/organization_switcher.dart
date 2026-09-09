import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/organizations/presentation/controllers/organizations_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart'
    show allBranchesSlug;
import '../i18n/strings.g.dart';
import '../permissions/current_user_permissions.dart';
import '../routing/router_utils.dart';
import '../routing/routes/dashboard.routes.dart';
import 'cached_avatar.dart';
import 'scope_switcher_bar.dart';
/// Width used when the switcher sits in unbounded parents (e.g. AppBar actions).
const _compactUnboundedWidth = 180.0;
const _regularUnboundedWidth = 260.0;

/// Organization switcher for super-admins to change the active tenant.
class OrganizationSwitcher extends ConsumerWidget {
  const OrganizationSwitcher({
    super.key,
    this.compact = false,
    this.embedded = false,
  });

  /// When true, uses tighter padding for the tablet/mobile top bar.
  final bool compact;

  /// When true, omits outer pill chrome (used inside [ScopeSwitcherBar]).
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final canSwitch = ref.watch(canUseOrganizationSwitcherProvider);

    if (!canSwitch) {
      return const SizedBox.shrink();
    }

    final currentOrgAsync = ref.watch(currentOrganizationControllerProvider);
    final organizationsAsync = ref.watch(organizationsControllerProvider);

    Widget buildBody() {
      return currentOrgAsync.when(
          skipLoadingOnReload: true,
          data: (currentOrg) {
            return organizationsAsync.when(
              data: (organizations) {
                if (organizations.isEmpty) {
                  return _OrganizationDisplay(
                    label: t.organizations.noOrganization,
                    compact: compact,
                    embedded: embedded,
                  );
                }

                final selectedId =
                    organizations.any((o) => o.id == currentOrg?.id)
                    ? currentOrg?.id
                    : organizations.first.id;

                final selectedOrg = organizations.firstWhere(
                  (o) => o.id == selectedId,
                  orElse: () => organizations.first,
                );

                return wrapSwitcherChrome(
                  theme: theme,
                  compact: compact,
                  embedded: embedded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedId,
                      isExpanded: true,
                      isDense: compact,
                      icon: const Icon(Icons.swap_horiz, size: 20),
                      hint: Text(t.organizations.switchOrganization),
                      selectedItemBuilder: (context) {
                        return organizations
                            .map(
                              (_) => Row(
                                children: [
                                  _OrganizationSwitcherLogo(
                                    logoUrl: selectedOrg.logoTransparentUrl,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedOrg.effectiveDisplayName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList();
                      },
                      items: organizations
                          .map(
                            (org) => DropdownMenuItem(
                              value: org.id,
                              child: Row(
                                children: [
                                  _OrganizationSwitcherLogo(
                                    logoUrl: org.logoTransparentUrl,
                                  ),
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
                        if (value == null) return;
                        final targetOrg = organizations.firstWhere(
                          (o) => o.id == value,
                          orElse: () => organizations.first,
                        );
                        final routerState = GoRouterState.of(context);
                        // Inside the org/branch-scoped shell: preserve the
                        // sub-path. Outside it (e.g. the /platform shell's
                        // "enter this org" switcher): no sub-path to
                        // preserve, land on the new org's dashboard.
                        final isScoped =
                            routerState.pathParameters['orgSlug'] != null;
                        final currentLocation = routerState.uri.path;
                        ref
                            .read(
                              currentOrganizationControllerProvider.notifier,
                            )
                            .switchOrganization(value)
                            .then((_) {
                              if (!context.mounted) return;
                              // Reset branch to "all" — the old branch almost
                              // certainly doesn't exist in the new org.
                              final target = isScoped
                                  ? RouterUtils.replaceScopeSegment(
                                      currentLocation,
                                      orgSlug: targetOrg.slug,
                                      branchSlug: allBranchesSlug,
                                    )
                                  : '/${targetOrg.slug}/$allBranchesSlug'
                                        '${DashboardRoute.path}';
                              context.go(target);
                            });
                      },
                    ),
                  ),
                );
              },
              loading: () => _OrganizationDisplay(
                label: t.common.loading,
                isLoading: true,
                compact: compact,
                embedded: embedded,
              ),
              error: (_, __) => _OrganizationDisplay(
                label:
                    currentOrg?.effectiveDisplayName ??
                    t.organizations.noOrganization,
                compact: compact,
                embedded: embedded,
              ),
            );
          },
          loading: () => _OrganizationDisplay(
            label: t.common.loading,
            isLoading: true,
            compact: compact,
            embedded: embedded,
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
    }

    if (embedded) return buildBody();

    return LayoutBuilder(
      builder: (context, constraints) {
        return _capUnboundedWidth(
          constraints: constraints,
          compact: compact,
          child: buildBody(),
        );
      },
    );
  }
}

Widget _capUnboundedWidth({
  required BoxConstraints constraints,
  required bool compact,
  required Widget child,
}) {
  if (constraints.maxWidth.isFinite) return child;
  return SizedBox(
    width: compact ? _compactUnboundedWidth : _regularUnboundedWidth,
    child: child,
  );
}

class _OrganizationSwitcherLogo extends StatelessWidget {
  const _OrganizationSwitcherLogo({this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CachedAvatar(
        imageUrl: logoUrl,
        radius: 9,
        placeholderIcon: Icons.apartment,
        thumbSize: 36,
      ),
    );
  }
}

class _OrganizationDisplay extends StatelessWidget {
  const _OrganizationDisplay({
    required this.label,
    this.isLoading = false,
    this.compact = false,
    this.embedded = false,
  });

  final String label;
  final bool isLoading;
  final bool compact;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return wrapSwitcherChrome(
      theme: theme,
      compact: compact,
      embedded: embedded,
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
