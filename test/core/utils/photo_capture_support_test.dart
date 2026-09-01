import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:hzn_gyms/src/core/utils/photo_capture_support.dart';
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

  group('isCameraBusyOrAbortError', () {
    test('is true for abort and notReadable codes', () {
      expect(
        isCameraBusyOrAbortError(
          CameraException('cameraAbort', 'Some problem occurred'),
        ),
        isTrue,
      );
      expect(
        isCameraBusyOrAbortError(
          CameraException('cameraNotReadable', 'not readable'),
        ),
        isTrue,
      );
    });

    test('is false for permission errors', () {
      expect(
        isCameraBusyOrAbortError(
          CameraException('CameraAccessDenied', 'Permission denied'),
        ),
        isFalse,
      );
    });

    test('is false for non-CameraException', () {
      expect(isCameraBusyOrAbortError(Exception('nope')), isFalse);
    });
  });

  group('classifyCameraInitFailure', () {
    test('retries same preset for busy/abort', () {
      expect(
        classifyCameraInitFailure(
          CameraException(
            'cameraAbort',
            'Some problem occurred that prevented the camera from being used.',
          ),
        ),
        CameraInitRetryAction.retrySamePreset,
      );
    });

    test('advances preset for overconstrained', () {
      expect(
        classifyCameraInitFailure(
          CameraException('cameraOverconstrained', 'overconstrained'),
        ),
        CameraInitRetryAction.advancePreset,
      );
    });

    test('fails for permission and other errors', () {
      expect(
        classifyCameraInitFailure(
          CameraException('CameraAccessDenied', 'Permission denied'),
        ),
        CameraInitRetryAction.fail,
      );
      expect(
        classifyCameraInitFailure(Exception('unknown')),
        CameraInitRetryAction.fail,
      );
    });
  });

  group('availableCamerasWithRetry', () {
    const frontCamera = CameraDescription(
      name: 'front',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 270,
    );

    test('returns cameras on first successful call', () async {
      final result = await availableCamerasWithRetry(
        enumerate: () async => [frontCamera],
      );
      expect(result, [frontCamera]);
    });

    test('retries on abort error and succeeds on subsequent attempt', () async {
      var calls = 0;
      final result = await availableCamerasWithRetry(
        enumerate: () async {
          calls++;
          if (calls == 1) {
            throw CameraException(
              'cameraAbort',
              'Some problem occurred that prevented the camera from being used.',
            );
          }
          return [frontCamera];
        },
      );
      expect(result, [frontCamera]);
      expect(calls, 2);
    });

    test('throws after exhausting retries on persistent abort', () async {
      var calls = 0;
      await expectLater(
        () => availableCamerasWithRetry(
          enumerate: () async {
            calls++;
            throw CameraException('cameraAbort', 'device busy');
          },
        ),
        throwsA(isA<CameraException>()),
      );
      expect(calls, cameraBusyRetryAttempts);
    });

    test('rethrows immediately on non-abort errors', () async {
      var calls = 0;
      await expectLater(
        () => availableCamerasWithRetry(
          enumerate: () async {
            calls++;
            throw CameraException('CameraAccessDenied', 'Permission denied');
          },
        ),
        throwsA(isA<CameraException>()),
      );
      expect(calls, 1);
    });

    test('cancellation short-circuits retries', () async {
      var calls = 0;
      final result = await availableCamerasWithRetry(
        isCancelled: () => true,
        enumerate: () async {
          calls++;
          return [frontCamera];
        },
      );
      expect(result, isEmpty);
      expect(calls, 0);
    });

    test('cancellation after first abort returns empty', () async {
      var calls = 0;
      var cancelled = false;

      final result = await availableCamerasWithRetry(
        isCancelled: () => cancelled,
        enumerate: () async {
          calls++;
          if (calls == 1) {
            cancelled = true;
            throw CameraException('cameraAbort', 'device busy');
          }
          return [frontCamera];
        },
      );
      expect(result, isEmpty);
      expect(calls, 1);
    });

    test('invokes onAttempt before each try', () async {
      final attempts = <int>[];
      await expectLater(
        () => availableCamerasWithRetry(
          onAttempt: attempts.add,
          enumerate: () async {
            throw CameraException('cameraAbort', 'device busy');
          },
        ),
        throwsA(isA<CameraException>()),
      );
      expect(attempts, List.generate(cameraBusyRetryAttempts, (i) => i + 1));
    });
  });

  group('shouldReportCameraRetryAttempts', () {
    test('is true for busy/abort after at least one attempt', () {
      expect(
        shouldReportCameraRetryAttempts(
          error: CameraException('cameraAbort', 'busy'),
          attemptsUsed: 1,
        ),
        isTrue,
      );
      expect(
        shouldReportCameraRetryAttempts(
          error: CameraException('cameraAbort', 'busy'),
          attemptsUsed: 3,
        ),
        isTrue,
      );
    });

    test('is false for non-retry errors even when attemptsUsed is set', () {
      expect(
        shouldReportCameraRetryAttempts(
          error: CameraException('CameraAccessDenied', 'Permission denied'),
          attemptsUsed: 1,
        ),
        isFalse,
      );
    });

    test('is false when no attempts were recorded', () {
      expect(
        shouldReportCameraRetryAttempts(
          error: CameraException('cameraAbort', 'busy'),
          attemptsUsed: 0,
        ),
        isFalse,
      );
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

    test('maps abort errors to busy/retry guidance', () {
      final error = CameraException(
        'cameraAbort',
        'Some problem occurred that prevented the camera from being used.',
      );
      expect(
        formatCameraInitError(error),
        contains('device busy or interrupted'),
      );
      expect(
        formatCameraInitError(error),
        isNot(contains('Some problem occurred')),
      );
    });

    test('maps notReadable to busy/retry guidance', () {
      final error = CameraException('cameraNotReadable', 'not readable');
      expect(
        formatCameraInitError(error),
        contains('device busy or interrupted'),
      );
    });

    test('returns camera description when available', () {
      final error = CameraException('other', 'Custom camera failure');
      expect(formatCameraInitError(error), 'Custom camera failure');
    });
  });

  group('fittedMemberPhotoPreviewSize', () {
    test('caps to maxSize when space is large', () {
      expect(
        fittedMemberPhotoPreviewSize(maxWidth: 800, maxHeight: 900),
        480,
      );
    });

    test('shrinks to fit width', () {
      expect(
        fittedMemberPhotoPreviewSize(maxWidth: 200, maxHeight: 900),
        200,
      );
    });

    test('shrinks to fit height minus chrome', () {
      expect(
        fittedMemberPhotoPreviewSize(
          maxWidth: 800,
          maxHeight: 300,
          chromeHeight: 140,
        ),
        160,
      );
    });

    test('floors at minSize when space is tiny', () {
      expect(
        fittedMemberPhotoPreviewSize(
          maxWidth: 50,
          maxHeight: 80,
          chromeHeight: 140,
          minSize: 120,
        ),
        120,
      );
    });

    test('new-member wizard caps at compact maxSize', () {
      expect(
        fittedMemberPhotoPreviewSize(
          maxWidth: 800,
          maxHeight: 900,
          maxSize: 160,
          chromeHeight: 180,
        ),
        160,
      );
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
