import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../packages/app_info/app_info_provider.dart';
import '../packages/pocketbase/pb_connectivity_provider.dart';
import '../packages/pocketbase/pocketbase_provider.dart';

/// Reusable widget displaying server domain, app version, and environment.
///
/// Shows:
/// - Online/offline status from PocketBase health
/// - Server domain: `staging.ebegym.com`
/// - Version and build number: `v1.0.0+1`
/// - Environment badge (only for non-prod): `DEV` or `STAGING`
class AppVersionIndicator extends ConsumerWidget {
  const AppVersionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appInfoAsync = ref.watch(appInfoProvider);
    final connectivityAsync = ref.watch(pbConnectivityProvider);
    final env = currentEnvironment;
    final serverUrl = pocketbaseUrl;

    // Extract domain from URL (remove protocol)
    final domain = Uri.parse(serverUrl).host;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Connectivity status
        connectivityAsync.when(
          data: (isOnline) => _ConnectivityStatus(isOnline: isOnline),
          loading: () => Text(
            'Checking…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontSize: 10,
            ),
          ),
          error: (_, __) => const _ConnectivityStatus(isOnline: false),
        ),
        const SizedBox(height: 4),

        // Server domain
        Text(
          domain,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),

        // Version and environment badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Version info
            appInfoAsync.when(
              data: (info) => Text(
                'v${info.version}+${info.buildNumber}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              loading: () => Text(
                'v...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Environment badge (only for non-prod)
            if (env != 'prod') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: env == 'dev'
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  env.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: env == 'dev' ? Colors.orange : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ConnectivityStatus extends StatelessWidget {
  const _ConnectivityStatus({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOnline ? Colors.green : Colors.orange;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
