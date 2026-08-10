import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/app_info/app_info_provider.dart';
import '../../../../core/packages/pocketbase/pb_connectivity_provider.dart';
import '../../../../core/widgets/app_version_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../check_in/presentation/widgets/rfid_listener_status_icon.dart';
import '../../domain/dashboard_greeting.dart';
import '../controllers/dashboard_refresh.dart';

/// Dashboard page header: greeting as title, connectivity + app version as subheader.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userName = ref.watch(currentAuthProvider)?.user.name;
    final greeting = dashboardGreeting(
      dateTime: DateTime.now(),
      userName: userName,
    );
    final appInfoAsync = ref.watch(appInfoProvider);
    final versionLabel = appInfoAsync.when(
      data: (info) => 'v${info.version}+${info.buildNumber}',
      loading: () => null,
      error: (_, __) => null,
    );
    final connectivityAsync = ref.watch(pbConnectivityProvider);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (versionLabel != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      connectivityAsync.when(
                        data: (isOnline) =>
                            ConnectivityStatusLabel(isOnline: isOnline),
                        loading: () => Text(
                          'Checking…',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 10,
                          ),
                        ),
                        error: (_, __) =>
                            const ConnectivityStatusLabel(isOnline: false),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        versionLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.75),
                          fontSize: 11,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const RfidListenerStatusIcon(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => refreshDashboard(ref),
          ),
        ],
      ),
    );
  }
}
