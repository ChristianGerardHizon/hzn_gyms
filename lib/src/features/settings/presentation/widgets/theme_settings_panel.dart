import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../../domain/app_theme_mode.dart';
import '../controllers/theme_controller.dart';

/// Panel for configuring app theme/appearance settings.
class ThemeSettingsPanel extends ConsumerWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeModeAsync = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        automaticallyImplyLeading: false,
      ),
      body: themeModeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState.fromError(
          error,
          compact: true,
          onRetry: () => ref.invalidate(themeControllerProvider),
        ),
        data: (currentMode) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Theme',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...AppThemeMode.values.map((mode) => _ThemeModeCard(
                  mode: mode,
                  isSelected: mode == currentMode,
                  onTap: () => controller.setThemeMode(mode),
                )),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            )
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            mode.icon,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          mode.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : null,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
        subtitle: Text(mode.description),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
