import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Result of processing a picked or captured image for member photo upload.
class CapturedPhoto {
  const CapturedPhoto({required this.bytes, required this.file});

  final Uint8List bytes;
  final XFile file;
}

/// Whether live [CameraController] preview is supported on the current platform.
bool isLiveCameraSupported() {
  if (kIsWeb) return true;
  return Platform.isAndroid || Platform.isIOS;
}

/// Web browsers require a user gesture before [getUserMedia] can open the camera.
bool requiresCameraUserGesture() => kIsWeb;

/// Whether the live camera session should be held open.
///
/// Returns false when the panel is inactive (e.g. another wizard step is
/// showing via [IndexedStack]) or a photo has already been captured, so the
/// underlying [CameraController] can be released.
bool shouldHoldLiveCamera({
  required bool canUseLiveCamera,
  required bool isActive,
  required bool hasCapturedPhoto,
}) {
  return canUseLiveCamera && isActive && !hasCapturedPhoto;
}

/// Whether [ImagePicker] with [ImageSource.camera] opens a real camera UI.
///
/// On web (especially desktop browsers) it falls back to a file picker, so callers
/// should use live [CameraController] preview instead.
bool isImagePickerCameraSupported() {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// User-facing label for a [CameraDescription] (name + lens direction).
String cameraDisplayLabel(CameraDescription camera) {
  final direction = switch (camera.lensDirection) {
    CameraLensDirection.front => 'Front',
    CameraLensDirection.back => 'Back',
    CameraLensDirection.external => 'External',
  };
  final name = camera.name.trim();
  if (name.isEmpty) return direction;
  return '$name ($direction)';
}

/// Returns [preferredCameraName] when it matches an available camera; otherwise
/// `null` meaning Automatic (front → external → back fallback).
String? resolvedCameraPreferenceName({
  required String? preferredCameraName,
  required List<CameraDescription> cameras,
}) {
  if (preferredCameraName == null || preferredCameraName.isEmpty) return null;
  if (cameras.any((c) => c.name == preferredCameraName)) {
    return preferredCameraName;
  }
  return null;
}

/// Picks the best available camera for member profile photos.
///
/// When [preferredName] matches a camera in [cameras], that device is used.
/// Otherwise falls back to front → external → back → first available.
CameraDescription selectPreferredCamera(
  List<CameraDescription> cameras, {
  String? preferredName,
}) {
  if (cameras.isEmpty) {
    throw ArgumentError.value(cameras, 'cameras', 'must not be empty');
  }

  if (preferredName != null && preferredName.isNotEmpty) {
    for (final camera in cameras) {
      if (camera.name == preferredName) return camera;
    }
  }

  for (final direction in [
    CameraLensDirection.front,
    CameraLensDirection.external,
    CameraLensDirection.back,
  ]) {
    final match = cameras.where((c) => c.lensDirection == direction);
    if (match.isNotEmpty) return match.first;
  }

  return cameras.first;
}

/// User-facing message for camera initialization failures.
String formatCameraInitError(Object error) {
  if (error is CameraException) {
    final code = error.code.toLowerCase();
    final description = (error.description ?? '').toLowerCase();

    if (code.contains('permission') || description.contains('permission')) {
      return 'Camera access was blocked. In Chrome, click the lock icon in the '
          'address bar, set Camera to Allow, then try again.';
    }
    if (code.contains('notreadable') || description.contains('not readable')) {
      return 'Camera is in use by another app. Close other apps using the '
          'camera, then try again.';
    }
    if (code.contains('notfound') || description.contains('not found')) {
      return 'No camera found on this device.';
    }
    if (code.contains('overconstrained') ||
        description.contains('overconstrained')) {
      return 'Could not use this camera at the requested quality. Try again or '
          'upload a photo instead.';
    }
    if (error.description != null && error.description!.isNotEmpty) {
      return error.description!;
    }
    return 'Camera error (${error.code}).';
  }

  return 'Camera is unavailable. Allow camera access in your browser, or upload '
      'a photo instead.';
}

/// Creates and initializes a [CameraController], retrying lower presets on web.
Future<CameraController> createInitializedCameraController(
  CameraDescription camera, {
  bool enableAudio = false,
}) async {
  final presets = kIsWeb
      ? [
          ResolutionPreset.low,
          ResolutionPreset.medium,
          ResolutionPreset.high,
        ]
      : [ResolutionPreset.medium];

  Object? lastError;
  for (final preset in presets) {
    final controller = CameraController(
      camera,
      preset,
      enableAudio: enableAudio,
    );
    try {
      await controller.initialize();
      return controller;
    } catch (error) {
      lastError = error;
      await controller.dispose();
    }
  }

  if (lastError != null) {
    Error.throwWithStackTrace(lastError!, StackTrace.current);
  }
  throw StateError('Failed to initialize camera');
}

/// Builds a stable filename for member photo uploads.
String memberPhotoFilename([DateTime? now]) {
  final timestamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
  return 'member_photo_$timestamp.jpg';
}

/// Square camera preview size that fits within [maxWidth] × [maxHeight].
///
/// [chromeHeight] reserves space for the camera switcher, action buttons, and
/// spacing that sit above/below the preview inside [MemberPhotoCapturePanel].
double fittedMemberPhotoPreviewSize({
  required double maxWidth,
  required double maxHeight,
  double maxSize = 480,
  double minSize = 120,
  double chromeHeight = 140,
}) {
  final widthBudget = maxWidth.isFinite ? maxWidth : maxSize;
  final heightBudget = maxHeight.isFinite
      ? (maxHeight - chromeHeight)
      : maxSize;
  final size = [
    maxSize,
    widthBudget,
    heightBudget,
  ].reduce((a, b) => a < b ? a : b);
  if (size < minSize) return minSize;
  if (size > maxSize) return maxSize;
  return size;
}

/// Reads image bytes and normalizes to a JPEG [XFile] for upload.
Future<CapturedPhoto?> processPickedOrCapturedImage(XFile file) async {
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) return null;

  final filename = memberPhotoFilename();
  return CapturedPhoto(
    bytes: bytes,
    file: XFile.fromData(bytes, name: filename, mimeType: 'image/jpeg'),
  );
}
