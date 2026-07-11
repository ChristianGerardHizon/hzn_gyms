// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csv_import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing CSV product import.

@ProviderFor(CsvImportController)
final csvImportControllerProvider = CsvImportControllerProvider._();

/// Controller for managing CSV product import.
final class CsvImportControllerProvider
    extends $NotifierProvider<CsvImportController, ImportState> {
  /// Controller for managing CSV product import.
  CsvImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'csvImportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$csvImportControllerHash();

  @$internal
  @override
  CsvImportController create() => CsvImportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportState>(value),
    );
  }
}

String _$csvImportControllerHash() =>
    r'5614038d8064f0455afad1e9fd85070383cba7ab';

/// Controller for managing CSV product import.

abstract class _$CsvImportController extends $Notifier<ImportState> {
  ImportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ImportState, ImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImportState, ImportState>,
              ImportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
