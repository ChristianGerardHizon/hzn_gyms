import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';

part 'camera_preference_controller.g.dart';

/// Storage key for persisting the preferred camera device name.
const cameraPreferenceKey = 'CAMERA_PREFERENCE';

/// Controller for the preferred camera device used for live photo capture.
///
/// Persists [CameraDescription.name] (or null for automatic lens fallback).
@Riverpod(keepAlive: true)
class CameraPreferenceController extends _$CameraPreferenceController {
  @override
  Future<String?> build() async {
    return _loadPersistedCameraName();
  }

  /// Sets the preferred camera name and persists it.
  ///
  /// Pass `null` or an empty string to clear (Automatic).
  Future<void> setPreferredCameraName(String? name) async {
    final normalized = (name == null || name.isEmpty) ? null : name;
    await _persistCameraName(normalized);
    state = AsyncData(normalized);
  }

  Future<String?> _loadPersistedCameraName() async {
    final storage = ref.read(secureStorageProvider);
    final value = await storage.read(key: cameraPreferenceKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> _persistCameraName(String? name) async {
    final storage = ref.read(secureStorageProvider);
    if (name == null) {
      await storage.delete(key: cameraPreferenceKey);
    } else {
      await storage.write(key: cameraPreferenceKey, value: name);
    }
  }
}
