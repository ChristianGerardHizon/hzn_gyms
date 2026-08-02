// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_preference_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for the preferred camera device used for live photo capture.
///
/// Persists [CameraDescription.name] (or null for automatic lens fallback).

@ProviderFor(CameraPreferenceController)
final cameraPreferenceControllerProvider =
    CameraPreferenceControllerProvider._();

/// Controller for the preferred camera device used for live photo capture.
///
/// Persists [CameraDescription.name] (or null for automatic lens fallback).
final class CameraPreferenceControllerProvider
    extends $AsyncNotifierProvider<CameraPreferenceController, String?> {
  /// Controller for the preferred camera device used for live photo capture.
  ///
  /// Persists [CameraDescription.name] (or null for automatic lens fallback).
  CameraPreferenceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraPreferenceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraPreferenceControllerHash();

  @$internal
  @override
  CameraPreferenceController create() => CameraPreferenceController();
}

String _$cameraPreferenceControllerHash() =>
    r'68d1c72ff54408afaedf0daa6a843db9eeb65e17';

/// Controller for the preferred camera device used for live photo capture.
///
/// Persists [CameraDescription.name] (or null for automatic lens fallback).

abstract class _$CameraPreferenceController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
