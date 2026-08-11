import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/sentry/report_camera_failure.dart';
import '../../../../core/utils/photo_capture_support.dart';
import '../controllers/camera_preference_controller.dart';

/// Sentinel value for the "Automatic" camera option.
const _automaticCameraValue = '';

/// Panel for configuring the default camera used for member photo capture.
class CameraSettingsPanel extends HookConsumerWidget {
  const CameraSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
      } catch (e, stackTrace) {
        await reportCameraFailure(e, stackTrace, phase: 'enumerate');
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
        title: const Text('Camera'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Default camera',
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
                final resolved = resolvedCameraPreferenceName(
                  preferredCameraName: preferredCameraName,
                  cameras: cameraList,
                );
                final selectedValue = resolved ?? _automaticCameraValue;

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
    );
  }
}
