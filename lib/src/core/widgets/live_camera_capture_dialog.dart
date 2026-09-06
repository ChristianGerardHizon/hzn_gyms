import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/presentation/controllers/camera_preference_controller.dart';
import '../packages/sentry/report_camera_failure.dart';
import '../utils/photo_capture_support.dart';

/// Opens a live camera popup and returns the captured photo, or null if cancelled.
Future<CapturedPhoto?> showLiveCameraCaptureDialog(
  BuildContext context, {
  String title = 'Capture photo',
  String? filename,
}) {
  return showDialog<CapturedPhoto>(
    context: context,
    barrierDismissible: true,
    // Nested above Record Payment — keep on the local navigator.
    useRootNavigator: false,
    builder: (context) => LiveCameraCaptureDialog(
      title: title,
      filename: filename,
    ),
  );
}

/// Dialog with a live [CameraPreview] and a capture shutter.
class LiveCameraCaptureDialog extends HookConsumerWidget {
  const LiveCameraCaptureDialog({
    super.key,
    this.title = 'Capture photo',
    this.filename,
  });

  final String title;

  /// Optional upload filename; defaults via [paymentProofFilename] /
  /// [memberPhotoFilename] in [processPickedOrCapturedImage] when null.
  final String? filename;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preferredCameraName =
        ref.watch(cameraPreferenceControllerProvider).value;
    final cameraController = useState<CameraController?>(null);
    final cameraError = useState<String?>(null);
    final isInitializing = useState(false);
    final isCapturing = useState(false);
    final cameraStarted = useState(false);
    final availableCameraList = useState<List<CameraDescription>>([]);
    final selectedCameraName = useState<String?>(null);
    final panelDisposed = useRef(false);
    final sessionGeneration = useRef(0);
    final releaseChain = useRef<Future<void>>(Future<void>.value());

    final canUseLiveCamera = isLiveCameraSupported();
    final needsUserGesture = requiresCameraUserGesture();

    Future<void> enqueueControllerDispose(CameraController? controller) {
      if (controller == null) return releaseChain.value;
      final release = releaseChain.value
          .then((_) => disposeCameraController(controller))
          .catchError((_) {});
      releaseChain.value = release;
      return release;
    }

    Future<void> releaseCamera() {
      final generation = ++sessionGeneration.value;
      final controller = cameraController.value;
      cameraController.value = null;
      cameraStarted.value = false;

      return enqueueControllerDispose(controller).then((_) {
        if (generation != sessionGeneration.value) return;
      });
    }

    Future<void> initCamera({
      bool Function()? isDisposed,
      String? forceCameraName,
      bool useAutomatic = false,
      String startTrigger = 'auto',
      bool hadController = false,
    }) async {
      final generation = ++sessionGeneration.value;
      bool isStale() =>
          generation != sessionGeneration.value ||
          isDisposed?.call() == true ||
          panelDisposed.value;

      await releaseChain.value;
      if (isStale()) return;

      isInitializing.value = true;
      cameraError.value = null;

      String? attemptedCameraName;
      var enumerateAttempts = 0;
      try {
        final cameras = await availableCamerasWithRetry(
          isCancelled: isStale,
          onAttempt: (attempt) => enumerateAttempts = attempt,
        );
        if (isStale()) return;

        enumerateAttempts = 0;
        availableCameraList.value = cameras;

        if (cameras.isEmpty) {
          cameraError.value = 'No camera found on this device.';
          return;
        }

        final preferred = useAutomatic
            ? null
            : (forceCameraName ??
                preferredCameraName ??
                selectedCameraName.value);
        final camera = selectPreferredCamera(
          cameras,
          preferredName: preferred,
        );
        attemptedCameraName = camera.name;
        final controller = await createInitializedCameraController(
          camera,
          enableAudio: false,
        );
        if (isStale()) {
          await enqueueControllerDispose(controller);
          return;
        }

        selectedCameraName.value = camera.name;
        cameraController.value = controller;
        cameraStarted.value = true;

        if (forceCameraName != null && forceCameraName == camera.name) {
          await ref
              .read(cameraPreferenceControllerProvider.notifier)
              .setPreferredCameraName(camera.name);
        }
      } on CameraException catch (e, stackTrace) {
        if (!isStale()) {
          final reportAttempts = shouldReportCameraRetryAttempts(
            error: e,
            attemptsUsed: enumerateAttempts,
          );
          await reportCameraFailure(
            e,
            stackTrace,
            phase: 'init',
            cameraName: attemptedCameraName,
            exceptionCode: e.code,
            startTrigger: startTrigger,
            hadController: hadController,
            attempt: reportAttempts ? enumerateAttempts : null,
            maxAttempts: reportAttempts ? cameraBusyRetryAttempts : null,
          );
          cameraError.value = formatCameraInitError(e);
        }
      } catch (e, stackTrace) {
        if (!isStale()) {
          final reportAttempts = shouldReportCameraRetryAttempts(
            error: e,
            attemptsUsed: enumerateAttempts,
          );
          await reportCameraFailure(
            e,
            stackTrace,
            phase: 'init',
            cameraName: attemptedCameraName,
            startTrigger: startTrigger,
            hadController: hadController,
            attempt: reportAttempts ? enumerateAttempts : null,
            maxAttempts: reportAttempts ? cameraBusyRetryAttempts : null,
          );
          cameraError.value = formatCameraInitError(e);
        }
      } finally {
        if (!isStale()) {
          isInitializing.value = false;
        }
      }
    }

    useEffect(() {
      return () {
        panelDisposed.value = true;
        releaseCamera();
      };
    }, const []);

    useEffect(() {
      if (!canUseLiveCamera) return null;

      var disposed = false;
      Future<void> loadCameras() async {
        try {
          final cameras = await availableCamerasWithRetry(
            isCancelled: () => disposed || panelDisposed.value,
          );
          if (!disposed && !panelDisposed.value) {
            availableCameraList.value = cameras;
          }
        } catch (_) {
          // initCamera surfaces errors.
        }
      }

      loadCameras();
      return () => disposed = true;
    }, [canUseLiveCamera]);

    useEffect(() {
      if (!canUseLiveCamera || needsUserGesture) return null;

      var cancelled = false;
      initCamera(
        isDisposed: () => cancelled || panelDisposed.value,
        startTrigger: 'auto',
      );
      return () {
        cancelled = true;
        releaseCamera();
      };
    }, [canUseLiveCamera, needsUserGesture]);

    Future<void> startCamera() async {
      if (panelDisposed.value) return;
      final hadController = cameraController.value != null;
      await releaseCamera();
      if (panelDisposed.value) return;
      await initCamera(
        isDisposed: () => panelDisposed.value,
        startTrigger: 'gesture',
        hadController: hadController,
      );
    }

    Future<void> switchCamera(String cameraName) async {
      if (panelDisposed.value) return;
      if (cameraName == selectedCameraName.value &&
          cameraController.value?.value.isInitialized == true) {
        return;
      }
      final hadController = cameraController.value != null;
      await releaseCamera();
      if (panelDisposed.value) return;
      await initCamera(
        isDisposed: () => panelDisposed.value,
        forceCameraName: cameraName,
        startTrigger: 'restart',
        hadController: hadController,
      );
    }

    Future<void> capturePhoto() async {
      final controller = cameraController.value;
      if (controller == null || !controller.value.isInitialized) return;
      if (isCapturing.value) return;

      isCapturing.value = true;
      try {
        final image = await controller.takePicture();
        final captured = await processPickedOrCapturedImage(
          image,
          filename: filename ?? paymentProofFilename(),
        );
        if (captured == null) {
          cameraError.value = 'Failed to capture photo.';
          return;
        }

        await releaseCamera();
        if (!context.mounted) return;
        Navigator.of(context).pop(captured);
      } on CameraException catch (e, stackTrace) {
        await reportCameraFailure(
          e,
          stackTrace,
          phase: 'capture',
          cameraName: selectedCameraName.value,
          exceptionCode: e.code,
          startTrigger: 'live',
          hadController: true,
        );
        cameraError.value = e.description ?? 'Failed to capture photo.';
      } finally {
        isCapturing.value = false;
      }
    }

    final showStartCamera = canUseLiveCamera &&
        needsUserGesture &&
        !cameraStarted.value &&
        cameraController.value?.value.isInitialized != true &&
        !isInitializing.value &&
        cameraError.value == null;

    final previewReady =
        cameraController.value?.value.isInitialized == true;
    final mediaSize = MediaQuery.sizeOf(context);
    final previewSize = fittedMemberPhotoPreviewSize(
      maxWidth: mediaSize.width - 64,
      maxHeight: mediaSize.height * 0.55,
      maxSize: 360,
      chromeHeight: 120,
    );

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: previewSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (availableCameraList.value.length > 1) ...[
              Builder(
                builder: (context) {
                  final cameras = availableCameraList.value;
                  final value = selectedCameraName.value ??
                      resolvedCameraPreferenceName(
                        preferredCameraName: preferredCameraName,
                        cameras: cameras,
                      ) ??
                      cameras.first.name;
                  return DropdownButtonFormField<String>(
                    key: ValueKey(value),
                    initialValue: value,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Camera',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: cameras
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
                            if (selected == null) return;
                            switchCamera(selected);
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            _LivePreviewFrame(
              previewSize: previewSize,
              controller: cameraController.value,
              isInitializing: isInitializing.value,
              errorMessage: cameraError.value,
              placeholderMessage: showStartCamera
                  ? 'Tap Start camera to enable your webcam.'
                  : canUseLiveCamera
                      ? null
                      : 'Live camera is not supported on this device.',
            ),
            if (cameraError.value != null) ...[
              const SizedBox(height: 12),
              Text(
                cameraError.value!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              isCapturing.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
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
        else if (previewReady)
          FilledButton.icon(
            onPressed: isCapturing.value ? null : capturePhoto,
            icon: isCapturing.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(isCapturing.value ? 'Capturing…' : 'Capture'),
          ),
      ],
    );
  }
}

class _LivePreviewFrame extends StatelessWidget {
  const _LivePreviewFrame({
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
      final aspectRatio = controller!.value.aspectRatio;
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: previewSize,
          height: previewSize,
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: previewSize,
              height: previewSize / (aspectRatio == 0 ? 1 : aspectRatio),
              child: preview,
            ),
          ),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
