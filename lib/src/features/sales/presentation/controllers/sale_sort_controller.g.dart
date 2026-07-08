// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_sort_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for managing sale list sort configuration.

@ProviderFor(SaleSortController)
final saleSortControllerProvider = SaleSortControllerProvider._();

/// Provider for managing sale list sort configuration.
final class SaleSortControllerProvider
    extends $NotifierProvider<SaleSortController, SortConfig> {
  /// Provider for managing sale list sort configuration.
  SaleSortControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleSortControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleSortControllerHash();

  @$internal
  @override
  SaleSortController create() => SaleSortController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SortConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SortConfig>(value),
    );
  }
}

String _$saleSortControllerHash() =>
    r'890319e9672e450bf03fb874810aff2bf32d6144';

/// Provider for managing sale list sort configuration.

abstract class _$SaleSortController extends $Notifier<SortConfig> {
  SortConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SortConfig, SortConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SortConfig, SortConfig>,
              SortConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
