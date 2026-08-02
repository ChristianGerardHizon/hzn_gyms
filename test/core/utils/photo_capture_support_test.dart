import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ebe_gym/src/core/utils/photo_capture_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('memberPhotoFilename', () {
    test('uses timestamp in filename', () {
      final now = DateTime(2026, 8, 2, 15, 30, 45, 123);
      expect(memberPhotoFilename(now), 'member_photo_${now.millisecondsSinceEpoch}.jpg');
    });
  });

  group('selectPreferredCamera', () {
    test('prefers external camera when available', () {
      final cameras = [
        const CameraDescription(
          name: 'back',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
        const CameraDescription(
          name: 'external',
          lensDirection: CameraLensDirection.external,
          sensorOrientation: 0,
        ),
      ];

      expect(selectPreferredCamera(cameras).name, 'external');
    });

    test('falls back to front then back camera', () {
      final cameras = [
        const CameraDescription(
          name: 'back',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
        const CameraDescription(
          name: 'front',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 270,
        ),
      ];

      expect(selectPreferredCamera(cameras).name, 'front');
    });

    test('throws when camera list is empty', () {
      expect(() => selectPreferredCamera([]), throwsArgumentError);
    });
  });

  group('processPickedOrCapturedImage', () {
    test('returns null for empty bytes', () async {
      final file = XFile.fromData(Uint8List(0), name: 'empty.jpg');
      expect(await processPickedOrCapturedImage(file), isNull);
    });

    test('returns normalized jpeg file with stable filename', () async {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
      final file = XFile.fromData(bytes, name: 'original.png');

      final result = await processPickedOrCapturedImage(file);

      expect(result, isNotNull);
      expect(result!.bytes, bytes);
      expect(result.file.mimeType, 'image/jpeg');
    });
  });
}
