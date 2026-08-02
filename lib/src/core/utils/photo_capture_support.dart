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
///
/// Web and desktop use [ImagePicker] for capture instead — the `camera` package
/// live preview is unreliable outside native Android/iOS.
bool isLiveCameraSupported() {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// Picks the best available camera for member profile photos.
CameraDescription selectPreferredCamera(List<CameraDescription> cameras) {
  if (cameras.isEmpty) {
    throw ArgumentError.value(cameras, 'cameras', 'must not be empty');
  }

  for (final direction in [
    CameraLensDirection.external,
    CameraLensDirection.front,
    CameraLensDirection.back,
  ]) {
    final match = cameras.where((c) => c.lensDirection == direction);
    if (match.isNotEmpty) return match.first;
  }

  return cameras.first;
}

/// Builds a stable filename for member photo uploads.
String memberPhotoFilename([DateTime? now]) {
  final timestamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
  return 'member_photo_$timestamp.jpg';
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
