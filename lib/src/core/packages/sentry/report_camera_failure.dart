import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sentry_flutter/sentry_flutter.dart';

/// Reports a camera failure to Sentry with structured tags/context.
///
/// Safe to call when Sentry is disabled (SDK no-ops without a DSN).
Future<void> reportCameraFailure(
  Object error,
  StackTrace stackTrace, {
  required String phase,
  String? cameraName,
  String? exceptionCode,
}) async {
  final code = exceptionCode ??
      (error is CameraException ? error.code : error.runtimeType.toString());

  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('feature', 'camera');
      scope.setTag('camera.phase', phase);
      scope.setTag('camera.code', code);
      scope.setContexts('camera', {
        'code': code,
        'description': error is CameraException ? error.description : null,
        'cameraName': cameraName,
        'isWeb': kIsWeb,
        'phase': phase,
      });
    },
  );
}
