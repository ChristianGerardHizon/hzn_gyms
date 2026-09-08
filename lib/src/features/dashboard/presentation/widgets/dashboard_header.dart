import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/app_info/app_info_provider.dart';
import '../../../../core/packages/pocketbase/pb_connectivity_provider.dart';
import '../../../../core/widgets/app_version_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../check_in/presentation/widgets/rfid_listener_status_icon.dart';
import '../../domain/dashboard_greeting.dart';
import '../controllers/dashboard_refresh.dart';

enum _RefreshUiState { idle, refreshing, done }

/// Dashboard page header: greeting as title, connectivity + app version as subheader.
class DashboardHeader extends HookConsumerWidget {
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

    final refreshState = useState(_RefreshUiState.idle);
    final spinController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    useEffect(() {
      if (refreshState.value == _RefreshUiState.refreshing) {
        spinController.repeat();
      } else {
        spinController
          ..stop()
          ..reset();
      }
      return null;
    }, [refreshState.value]);

    Future<void> onRefresh() async {
      if (refreshState.value != _RefreshUiState.idle) return;
      refreshState.value = _RefreshUiState.refreshing;
      await refreshDashboard(ref);
      if (!context.mounted) return;
      refreshState.value = _RefreshUiState.done;
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (!context.mounted) return;
      refreshState.value = _RefreshUiState.idle;
    }

    final (icon, label) = switch (refreshState.value) {
      _RefreshUiState.idle => (Icons.refresh, 'Refresh'),
      _RefreshUiState.refreshing => (Icons.refresh, 'Refreshing…'),
      _RefreshUiState.done => (Icons.check, 'Done'),
    };

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
          TextButton.icon(
            onPressed: refreshState.value == _RefreshUiState.refreshing
                ? null
                : onRefresh,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: refreshState.value == _RefreshUiState.refreshing
                  ? RotationTransition(
                      key: const ValueKey('refreshing'),
                      turns: spinController,
                      child: Icon(icon),
                    )
                  : Icon(
                      icon,
                      key: ValueKey(refreshState.value),
                    ),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                key: ValueKey(label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
