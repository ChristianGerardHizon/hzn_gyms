import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/settings/presentation/controllers/camera_preference_controller.dart';
import '../utils/photo_capture_support.dart';
import 'cached_avatar.dart';

/// Live camera capture with gallery upload fallback for member profile photos.
class MemberPhotoCapturePanel extends HookConsumerWidget {
  const MemberPhotoCapturePanel({
    super.key,
    required this.photoBytes,
    required this.selectedPhoto,
    this.previewSize = 280,
    this.avatarRadius = 64,
    this.existingPhotoUrl,
    this.isActive = true,
  });

  final ValueNotifier<Uint8List?> photoBytes;
  final ValueNotifier<XFile?> selectedPhoto;
  final double previewSize;
  final double avatarRadius;
  final String? existingPhotoUrl;

  /// When false (e.g. another wizard step is visible), the camera is released.
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useListenable(photoBytes);
    useListenable(selectedPhoto);

    final theme = Theme.of(context);
    final preferredCameraName =
        ref.watch(cameraPreferenceControllerProvider).value;
    final cameraController = useState<CameraController?>(null);
    final cameraError = useState<String?>(null);
    final isInitializing = useState(false);
    final cameraSessionKey = useState(0);
    final cameraStarted = useState(false);
    final availableCameraList = useState<List<CameraDescription>>([]);
    final selectedCameraName = useState<String?>(null);
    final panelDisposed = useRef(false);
    final isActiveRef = useRef(isActive);
    isActiveRef.value = isActive;

    final hasCapturedPhoto = photoBytes.value != null;
    final canUseLiveCamera = isLiveCameraSupported();
    final needsUserGesture = requiresCameraUserGesture();
    final holdLiveCamera = shouldHoldLiveCamera(
      canUseLiveCamera: canUseLiveCamera,
      isActive: isActive,
      hasCapturedPhoto: hasCapturedPhoto,
    );

    bool isSessionCancelled() =>
        panelDisposed.value || !isActiveRef.value;

    void releaseCamera() {
      final controller = cameraController.value;
      cameraController.value = null;
      cameraStarted.value = false;
      controller?.dispose();
    }

    Future<void> initCamera({
      bool Function()? isDisposed,
      String? forceCameraName,
    }) async {
      isInitializing.value = true;
      cameraError.value = null;

      try {
        final cameras = await availableCameras();
        if (isDisposed?.call() == true) return;

        availableCameraList.value = cameras;

        if (cameras.isEmpty) {
          cameraError.value = 'No camera found on this device.';
          return;
        }

        final preferred =
            forceCameraName ?? preferredCameraName ?? selectedCameraName.value;
        final camera = selectPreferredCamera(
          cameras,
          preferredName: preferred,
        );
        final controller = await createInitializedCameraController(
          camera,
          enableAudio: false,
        );
        if (isDisposed?.call() == true) {
          await controller.dispose();
          return;
        }

        selectedCameraName.value = camera.name;
        cameraController.value = controller;
        cameraStarted.value = true;

        // Persist only explicit user picks (camera switcher). Do not overwrite
        // Appearance → Automatic when falling back to a default lens.
        if (forceCameraName != null && forceCameraName == camera.name) {
          await ref
              .read(cameraPreferenceControllerProvider.notifier)
              .setPreferredCameraName(camera.name);
        }
      } on CameraException catch (e) {
        if (isDisposed?.call() != true) {
          cameraError.value = formatCameraInitError(e);
        }
      } catch (e) {
        if (isDisposed?.call() != true) {
          cameraError.value = formatCameraInitError(e);
        }
      } finally {
        if (isDisposed?.call() != true) {
          isInitializing.value = false;
        }
      }
    }

    // Always release the camera when this panel is removed from the tree
    // (including web, where start is gesture-driven and auto-init is skipped).
    useEffect(() {
      return () {
        panelDisposed.value = true;
        releaseCamera();
      };
    }, const []);

    // Enumerate cameras early so the switcher can appear before preview starts.
    useEffect(() {
      if (!holdLiveCamera) return null;

      var disposed = false;

      Future<void> loadCameras() async {
        try {
          final cameras = await availableCameras();
          if (!disposed && !isSessionCancelled()) {
            availableCameraList.value = cameras;
          }
        } catch (_) {
          // Listing can fail before permission; initCamera will surface errors.
        }
      }

      loadCameras();
      return () => disposed = true;
    }, [holdLiveCamera, cameraSessionKey.value]);

    // Auto-init on platforms that allow camera without a user gesture.
    // Always register cleanup so inactive / photo-captured / unmount release
    // the stream (IndexedStack keeps steps mounted across wizard navigation).
    useEffect(() {
      if (!holdLiveCamera) {
        releaseCamera();
        return null;
      }

      if (needsUserGesture) {
        // Web: wait for Start camera; still release when becoming inactive.
        return () => releaseCamera();
      }

      var cancelled = false;

      Future<void> autoInit() async {
        await initCamera(
          isDisposed: () => cancelled || isSessionCancelled(),
        );
      }

      autoInit();

      return () {
        cancelled = true;
        releaseCamera();
      };
    }, [holdLiveCamera, needsUserGesture, cameraSessionKey.value]);

    Future<void> startCamera() async {
      if (isSessionCancelled()) return;

      final existing = cameraController.value;
      cameraController.value = null;
      await existing?.dispose();

      cameraStarted.value = false;
      await initCamera(isDisposed: isSessionCancelled);
    }

    Future<void> switchCamera(String cameraName) async {
      if (isSessionCancelled()) return;
      if (cameraName == selectedCameraName.value &&
          cameraController.value?.value.isInitialized == true) {
        return;
      }

      final existing = cameraController.value;
      cameraController.value = null;
      await existing?.dispose();

      cameraStarted.value = false;
      await initCamera(
        isDisposed: isSessionCancelled,
        forceCameraName: cameraName,
      );
    }

    Future<void> applyCaptured(CapturedPhoto captured) async {
      final controller = cameraController.value;
      cameraController.value = null;
      await controller?.dispose();

      photoBytes.value = captured.bytes;
      selectedPhoto.value = captured.file;
    }

    Future<void> pickFromGallery() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image == null) return;

      final captured = await processPickedOrCapturedImage(image);
      if (captured == null) return;

      await applyCaptured(captured);
    }

    Future<void> pickFromCamera() async {
      final picker = ImagePicker();
      try {
        final image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
        if (image == null) return;

        final captured = await processPickedOrCapturedImage(image);
        if (captured == null) return;

        cameraError.value = null;
        await applyCaptured(captured);
      } catch (_) {
        cameraError.value =
            'Could not open the camera. Try uploading a photo instead.';
      }
    }

    Future<void> capturePhoto() async {
      final controller = cameraController.value;
      if (controller == null || !controller.value.isInitialized) return;

      try {
        final image = await controller.takePicture();
        final captured = await processPickedOrCapturedImage(image);
        if (captured == null) return;

        cameraController.value = null;
        await controller.dispose();

        photoBytes.value = captured.bytes;
        selectedPhoto.value = captured.file;
      } on CameraException catch (e) {
        cameraError.value = e.description ?? 'Failed to capture photo.';
      }
    }

    void retake() {
      photoBytes.value = null;
      selectedPhoto.value = null;
      cameraError.value = null;
      cameraStarted.value = false;
      cameraSessionKey.value++;
    }

    final showStartCamera = holdLiveCamera &&
        needsUserGesture &&
        !cameraStarted.value &&
        cameraController.value?.value.isInitialized != true &&
        !isInitializing.value &&
        cameraError.value == null;

    final showCameraSwitcher = holdLiveCamera &&
        availableCameraList.value.length > 1;

    if (hasCapturedPhoto) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: MemoryImage(photoBytes.value!),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: retake,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake'),
              ),
              OutlinedButton.icon(
                onPressed: pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload different photo'),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (existingPhotoUrl != null && existingPhotoUrl!.isNotEmpty) ...[
          CachedAvatar(radius: avatarRadius, imageUrl: existingPhotoUrl),
          const SizedBox(height: 16),
        ] else if (!canUseLiveCamera) ...[
          CachedAvatar(radius: avatarRadius),
          const SizedBox(height: 16),
        ],
        if (showCameraSwitcher) ...[
          Builder(
            builder: (context) {
              final cameraList = availableCameraList.value;
              final currentName = selectedCameraName.value ??
                  preferredCameraName ??
                  cameraList.first.name;
              final value = cameraList.any((c) => c.name == currentName)
                  ? currentName
                  : cameraList.first.name;

              return SizedBox(
                width: previewSize,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(value),
                  initialValue: value,
                  decoration: const InputDecoration(
                    labelText: 'Camera',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: cameraList
                      .map(
                        (camera) => DropdownMenuItem(
                          value: camera.name,
                          child: Text(
                            cameraDisplayLabel(camera),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isInitializing.value
                      ? null
                      : (selected) {
                          if (selected != null) switchCamera(selected);
                        },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        if (canUseLiveCamera) ...[
          _CameraPreviewFrame(
            previewSize: previewSize,
            controller: cameraController.value,
            isInitializing: isInitializing.value,
            errorMessage: cameraError.value,
            placeholderMessage: showStartCamera
                ? 'Tap Start camera to enable your webcam.'
                : null,
          ),
          const SizedBox(height: 16),
        ],
        if (cameraError.value != null) ...[
          Text(
            cameraError.value!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (showStartCamera)
              FilledButton.icon(
                onPressed: startCamera,
                icon: const Icon(Icons.videocam),
                label: const Text('Start camera'),
              )
            else if (cameraError.value != null && canUseLiveCamera)
              FilledButton.icon(
                onPressed: startCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              )
            else if (canUseLiveCamera &&
                cameraController.value?.value.isInitialized == true)
              FilledButton.icon(
                onPressed: capturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture'),
              )
            else if (isImagePickerCameraSupported())
              FilledButton.icon(
                onPressed: pickFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take photo'),
              ),
            OutlinedButton.icon(
              onPressed: pickFromGallery,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload from file'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CameraPreviewFrame extends StatelessWidget {
  const _CameraPreviewFrame({
    required this.previewSize,
    required this.controller,
    required this.isInitializing,
    required this.errorMessage,
    this.placeholderMessage,
  });

  final double previewSize;
  final CameraController? controller;
  final bool isInitializing;
  final String? errorMessage;
  final String? placeholderMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;
    if (isInitializing) {
      child = const Center(child: CircularProgressIndicator());
    } else if (controller != null && controller!.value.isInitialized) {
      final preview = CameraPreview(controller!);
      child = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: kIsWeb
            ? SizedBox(
                width: previewSize,
                height: previewSize,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: previewSize,
                    height: previewSize / controller!.value.aspectRatio,
                    child: preview,
                  ),
                ),
              )
            : AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: preview,
              ),
      );
    } else {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            errorMessage ??
                placeholderMessage ??
                'Camera preview unavailable.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      width: previewSize,
      height: previewSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
