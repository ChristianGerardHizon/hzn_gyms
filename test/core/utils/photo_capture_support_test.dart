import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ebe_gym/src/core/utils/photo_capture_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isLiveCameraSupported', () {
    test('returns false in test VM (not Android/iOS native or web)', () {
      expect(isLiveCameraSupported(), isFalse);
    });
  });

  group('requiresCameraUserGesture', () {
    test('returns false in test VM (web-only behavior)', () {
      expect(requiresCameraUserGesture(), isFalse);
    });
  });

  group('shouldHoldLiveCamera', () {
    test('holds only when live camera is supported, active, and no photo', () {
      expect(
        shouldHoldLiveCamera(
          canUseLiveCamera: true,
          isActive: true,
          hasCapturedPhoto: false,
        ),
        isTrue,
      );
    });

    test('releases when panel is inactive (e.g. another wizard step)', () {
      expect(
        shouldHoldLiveCamera(
          canUseLiveCamera: true,
          isActive: false,
          hasCapturedPhoto: false,
        ),
        isFalse,
      );
    });

    test('releases after a photo has been captured', () {
      expect(
        shouldHoldLiveCamera(
          canUseLiveCamera: true,
          isActive: true,
          hasCapturedPhoto: true,
        ),
        isFalse,
      );
    });

    test('releases when live camera is unsupported', () {
      expect(
        shouldHoldLiveCamera(
          canUseLiveCamera: false,
          isActive: true,
          hasCapturedPhoto: false,
        ),
        isFalse,
      );
    });
  });

  group('isImagePickerCameraSupported', () {
    test('returns false in test VM', () {
      expect(isImagePickerCameraSupported(), isFalse);
    });
  });

  group('memberPhotoFilename', () {
    test('uses timestamp in filename', () {
      final now = DateTime(2026, 8, 2, 15, 30, 45, 123);
      expect(memberPhotoFilename(now), 'member_photo_${now.millisecondsSinceEpoch}.jpg');
    });
  });

  group('cameraDisplayLabel', () {
    test('includes name and lens direction', () {
      expect(
        cameraDisplayLabel(
          const CameraDescription(
            name: 'FaceTime HD',
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 0,
          ),
        ),
        'FaceTime HD (Front)',
      );
    });

    test('uses direction only when name is blank', () {
      expect(
        cameraDisplayLabel(
          const CameraDescription(
            name: '  ',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        ),
        'Back',
      );
    });
  });

  group('resolvedCameraPreferenceName', () {
    const cameras = [
      CameraDescription(
        name: 'front',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 270,
      ),
      CameraDescription(
        name: 'back',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
    ];

    test('returns preferred name when it matches', () {
      expect(
        resolvedCameraPreferenceName(
          preferredCameraName: 'back',
          cameras: cameras,
        ),
        'back',
      );
    });

    test('returns null for automatic when preferred is null or empty', () {
      expect(
        resolvedCameraPreferenceName(
          preferredCameraName: null,
          cameras: cameras,
        ),
        isNull,
      );
      expect(
        resolvedCameraPreferenceName(
          preferredCameraName: '',
          cameras: cameras,
        ),
        isNull,
      );
    });

    test('returns null when preferred camera is unavailable', () {
      expect(
        resolvedCameraPreferenceName(
          preferredCameraName: 'missing',
          cameras: cameras,
        ),
        isNull,
      );
    });
  });

  group('selectPreferredCamera', () {
    test('prefers front camera for profile photos when available', () {
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
        const CameraDescription(
          name: 'external',
          lensDirection: CameraLensDirection.external,
          sensorOrientation: 0,
        ),
      ];

      expect(selectPreferredCamera(cameras).name, 'front');
    });

    test('uses preferredName when it matches an available camera', () {
      final cameras = [
        const CameraDescription(
          name: 'front',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 270,
        ),
        const CameraDescription(
          name: 'usb-cam',
          lensDirection: CameraLensDirection.external,
          sensorOrientation: 0,
        ),
      ];

      expect(
        selectPreferredCamera(cameras, preferredName: 'usb-cam').name,
        'usb-cam',
      );
    });

    test('falls back when preferredName is missing from the list', () {
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

      expect(
        selectPreferredCamera(cameras, preferredName: 'gone').name,
        'front',
      );
    });

    test('falls back to external then back camera', () {
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

    test('throws when camera list is empty', () {
      expect(() => selectPreferredCamera([]), throwsArgumentError);
    });
  });

  group('formatCameraInitError', () {
    test('maps permission errors to browser guidance', () {
      final error = CameraException('permissionDenied', 'Permission denied');
      expect(
        formatCameraInitError(error),
        contains('lock icon'),
      );
    });

    test('returns camera description when available', () {
      final error = CameraException('other', 'Custom camera failure');
      expect(formatCameraInitError(error), 'Custom camera failure');
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
