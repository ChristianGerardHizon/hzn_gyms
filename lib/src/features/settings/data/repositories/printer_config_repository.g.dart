// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the PrinterConfigRepository instance.

@ProviderFor(printerConfigRepository)
final printerConfigRepositoryProvider = PrinterConfigRepositoryProvider._();

/// Provides the PrinterConfigRepository instance.

final class PrinterConfigRepositoryProvider
    extends
        $FunctionalProvider<
          PrinterConfigRepository,
          PrinterConfigRepository,
          PrinterConfigRepository
        >
    with $Provider<PrinterConfigRepository> {
  /// Provides the PrinterConfigRepository instance.
  PrinterConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printerConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printerConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<PrinterConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrinterConfigRepository create(Ref ref) {
    return printerConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrinterConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrinterConfigRepository>(value),
    );
  }
}

String _$printerConfigRepositoryHash() =>
    r'a909fc4c7d364ba15d485ea768cf7318803d6722';
