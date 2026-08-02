import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/photo_capture_support.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/app_theme_mode.dart';
import '../controllers/camera_preference_controller.dart';
import '../controllers/theme_controller.dart';

/// Sentinel value for the "Automatic" camera option in Appearance settings.
const _automaticCameraValue = '';

/// Panel for configuring app theme/appearance settings.
class ThemeSettingsPanel extends HookConsumerWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeModeAsync = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final preferredCameraName =
        ref.watch(cameraPreferenceControllerProvider).value;
    final cameraPreferenceNotifier =
        ref.read(cameraPreferenceControllerProvider.notifier);

    final cameras = useState<List<CameraDescription>?>(null);
    final camerasError = useState<String?>(null);
    final camerasLoading = useState(false);

    Future<void> loadCameras() async {
      camerasLoading.value = true;
      camerasError.value = null;
      try {
        cameras.value = await availableCameras();
      } catch (e) {
        camerasError.value = formatCameraInitError(e);
        cameras.value = const [];
      } finally {
        camerasLoading.value = false;
      }
    }

    useEffect(() {
      loadCameras();
      return null;
    }, const []);

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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Camera',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Default camera for member photo capture. '
                'Automatic prefers front, then external, then back.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (camerasLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (camerasError.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camerasError.value!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: loadCameras,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (cameras.value == null || cameras.value!.isEmpty)
              Text(
                'No camera found on this device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Builder(
                builder: (context) {
                  final cameraList = cameras.value!;
                  final selectedValue =
                      (preferredCameraName != null &&
                              cameraList
                                  .any((c) => c.name == preferredCameraName))
                          ? preferredCameraName
                          : _automaticCameraValue;

                  return DropdownButtonFormField<String>(
                    key: ValueKey(selectedValue),
                    initialValue: selectedValue,
                    decoration: const InputDecoration(
                      labelText: 'Default camera',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: _automaticCameraValue,
                        child: Text('Automatic'),
                      ),
                      ...cameraList.map(
                        (camera) => DropdownMenuItem(
                          value: camera.name,
                          child: Text(
                            cameraDisplayLabel(camera),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      cameraPreferenceNotifier.setPreferredCameraName(
                        value == _automaticCameraValue ? null : value,
                      );
                    },
                  );
                },
              ),
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
