import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'camera_document_visibility_stub.dart'
    if (dart.library.html) 'camera_document_visibility_web.dart'
    as document_visibility;

/// Builds the structured camera context map sent to Sentry.
///
/// Pure helper so unit tests can assert keys without invoking the Sentry SDK.
Map<String, Object?> buildCameraFailureContext({
  required String code,
  required String phase,
  String? description,
  String? cameraName,
  String? lifecycleState,
  String? documentVisibility,
  String? startTrigger,
  bool? hadController,
  int? attempt,
  int? maxAttempts,
  bool isWeb = kIsWeb,
}) {
  return {
    'code': code,
    'description': description,
    'cameraName': cameraName,
    'isWeb': isWeb,
    'phase': phase,
    'lifecycleState': lifecycleState,
    'documentVisibility': documentVisibility,
    'startTrigger': startTrigger,
    'hadController': hadController,
    'attempt': attempt,
    'maxAttempts': maxAttempts,
  };
}

/// Reports a camera failure to Sentry with structured tags/context.
///
/// Safe to call when Sentry is disabled (SDK no-ops without a DSN).
///
/// Automatically attaches Flutter [AppLifecycleState] and (on web) document
/// visibility. Optional fields let callers add retry / UX context.
Future<void> reportCameraFailure(
  Object error,
  StackTrace stackTrace, {
  required String phase,
  String? cameraName,
  String? exceptionCode,
  String? startTrigger,
  bool? hadController,
  int? attempt,
  int? maxAttempts,
}) async {
  final code = exceptionCode ??
      (error is CameraException ? error.code : error.runtimeType.toString());
  final description = error is CameraException ? error.description : null;
  final lifecycleState = _readLifecycleStateName();
  final documentVisibility =
      document_visibility.readCameraDocumentVisibility();

  final context = buildCameraFailureContext(
    code: code,
    description: description,
    cameraName: cameraName,
    phase: phase,
    lifecycleState: lifecycleState,
    documentVisibility: documentVisibility,
    startTrigger: startTrigger,
    hadController: hadController,
    attempt: attempt,
    maxAttempts: maxAttempts,
  );

  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('feature', 'camera');
      scope.setTag('camera.phase', phase);
      scope.setTag('camera.code', code);
      if (startTrigger != null) {
        scope.setTag('camera.startTrigger', startTrigger);
      }
      if (lifecycleState != null) {
        scope.setTag('camera.lifecycle', lifecycleState);
      }
      if (documentVisibility != null) {
        scope.setTag('camera.documentVisibility', documentVisibility);
      }
      if (attempt != null) {
        scope.setTag('camera.attempt', '$attempt');
      }
      scope.setContexts('camera', context);
      scope.addBreadcrumb(
        Breadcrumb(
          category: 'camera',
          message: 'camera.$phase failed',
          level: SentryLevel.error,
          data: {
            for (final entry in context.entries)
              if (entry.value != null) entry.key: entry.value,
          },
        ),
      );
    },
  );
}

String? _readLifecycleStateName() {
  try {
    return WidgetsBinding.instance.lifecycleState?.name;
  } catch (_) {
    return null;
  }
}
