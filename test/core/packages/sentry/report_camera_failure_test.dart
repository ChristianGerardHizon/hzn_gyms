import 'package:kylie_gym/src/core/packages/sentry/report_camera_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildCameraFailureContext', () {
    test('includes core failure fields', () {
      final context = buildCameraFailureContext(
        code: 'cameraAbort',
        description: 'device busy',
        cameraName: 'FaceTime HD',
        phase: 'init',
        isWeb: true,
      );

      expect(context['code'], 'cameraAbort');
      expect(context['description'], 'device busy');
      expect(context['cameraName'], 'FaceTime HD');
      expect(context['phase'], 'init');
      expect(context['isWeb'], isTrue);
    });

    test('includes diagnostic enrichment fields when provided', () {
      final context = buildCameraFailureContext(
        code: 'cameraAbort',
        phase: 'init',
        lifecycleState: 'inactive',
        documentVisibility: 'hidden',
        startTrigger: 'gesture',
        hadController: true,
        attempt: 3,
        maxAttempts: 3,
        isWeb: true,
      );

      expect(context['lifecycleState'], 'inactive');
      expect(context['documentVisibility'], 'hidden');
      expect(context['startTrigger'], 'gesture');
      expect(context['hadController'], isTrue);
      expect(context['attempt'], 3);
      expect(context['maxAttempts'], 3);
    });

    test('keeps optional enrichment fields null when omitted', () {
      final context = buildCameraFailureContext(
        code: 'CameraAccessDenied',
        phase: 'enumerate',
        isWeb: false,
      );

      expect(context['lifecycleState'], isNull);
      expect(context['documentVisibility'], isNull);
      expect(context['startTrigger'], isNull);
      expect(context['hadController'], isNull);
      expect(context['attempt'], isNull);
      expect(context['maxAttempts'], isNull);
    });
  });
}
